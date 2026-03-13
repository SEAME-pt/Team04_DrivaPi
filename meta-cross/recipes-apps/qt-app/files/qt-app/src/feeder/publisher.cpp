/**
 * @file publisher.cpp
 * @brief KUKSA VAL v2 publisher implementation
 */

#include "publisher.hpp"
#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>
#include <google/protobuf/timestamp.pb.h>

using namespace kuksa;

namespace feeder {

// Returns true if the address targets the loopback interface (127.x.x.x, localhost, ::1).
// Used to guard against insecure channels being accidentally opened over the network.
static bool IsLoopback(const std::string& address)
{
    return address.find("localhost") == 0
        || address.find("127.") == 0
        || address.find("[::1]") == 0;
}

Publisher::Publisher(const std::string& address) {
    if (!IsLoopback(address)) {
        std::cerr << "[Publisher] WARNING: insecure channel requested for non-loopback address '"
                  << address << "'. Vehicle telemetry will be transmitted in plaintext. "
                  << "Use PublisherOptions with use_ssl=true to enable TLS." << std::endl;
    }
    channel_ = grpc::CreateChannel(address, grpc::InsecureChannelCredentials());
    stub_ = val::v2::VAL::NewStub(channel_);
    std::cout << "[Publisher] Connected to KUKSA databroker at " << address << std::endl;
}

Publisher::Publisher(const PublisherOptions& options)
    : options_(options)
{
    std::shared_ptr<grpc::ChannelCredentials> channel_credentials;
    if (!options_.use_ssl) {
        if (!IsLoopback(options_.address)) {
            std::cerr << "[Publisher] WARNING: insecure channel requested for non-loopback address '"
                      << options_.address << "'. Vehicle telemetry will be transmitted in plaintext. "
                      << "Pass --tls to enable encryption." << std::endl;
        }
        channel_credentials = grpc::InsecureChannelCredentials();
    } else {
        grpc::SslCredentialsOptions ssl_options;
        const std::string root_certificate = LoadFile(options_.root_ca_path);
        if (!root_certificate.empty()) ssl_options.pem_root_certs = root_certificate;
        const std::string client_certificate = LoadFile(options_.client_cert_path);
        const std::string private_key = LoadFile(options_.client_key_path);
        if (!client_certificate.empty() && !private_key.empty()) {
            ssl_options.pem_cert_chain = client_certificate;
            ssl_options.pem_private_key = private_key;
        }
        channel_credentials = grpc::SslCredentials(ssl_options);
    }

    channel_ = grpc::CreateChannel(options_.address, channel_credentials);
    stub_ = val::v2::VAL::NewStub(channel_);
    // Verify channel connectivity (blocks briefly)
    if (!channel_->WaitForConnected(std::chrono::system_clock::now() + std::chrono::seconds(2))) {
        std::cerr << "[Publisher] Warning: Channel not connected to " << options_.address 
                  << " (broker may be unreachable)" << std::endl;
    }
    std::cout << "[Publisher] Connected to KUKSA databroker at " << options_.address
              << (options_.use_ssl ? " (TLS)" : " (insecure)") << std::endl;
    if (!options_.token.empty()) {
        std::cout << "[Publisher] Using Authorization token" << std::endl;
    }
}

Publisher::~Publisher() {
    // Signal reader thread to stop and close provider stream cleanly
    stream_stop_.store(true);
    {
        std::lock_guard<std::mutex> lg(stream_mutex_);
        if (stream_) {
            stream_->WritesDone();
        }
        if (stream_ctx_) {
            stream_ctx_->TryCancel();
        }
    }
    if (stream_reader_thread_.joinable()) {
        stream_reader_thread_.join();
    }

    // Explicitly release gRPC objects so their memory is freed before grpc_shutdown()
    stream_.reset();
    stream_ctx_.reset();
    stub_.reset();
    channel_.reset();
}

bool Publisher::PublishDouble(const std::string& path, double value) {
    grpc::ClientContext context;
    AttachAuth(context);
    val::v2::PublishValueRequest request;
    val::v2::PublishValueResponse response;

    request.mutable_signal_id()->set_path(path);
    request.mutable_data_point()->mutable_value()->set_double_(value);

    grpc::Status status = stub_->PublishValue(&context, request, &response);
    
    if (!status.ok()) {
        std::cerr << "[Publisher] PublishValue(" << path << ", " << value
                  << ") failed: code=" << status.error_code()
                  << " msg='" << status.error_message() << "'" << std::endl;
        return false;
    }
    
    return true;
}

bool Publisher::PublishFloat(const std::string& path, float value) {
    // Try provider-stream publishing first
    int32_t signal_id = LookupSignalId(path);
    if (signal_id >= 0) {
        if (EnsureProviderStream()) {
            std::shared_ptr<grpc::ClientReaderWriter<kuksa::val::v2::OpenProviderStreamRequest,
                                                     kuksa::val::v2::OpenProviderStreamResponse>> local_stream;
            {
                std::lock_guard<std::mutex> lg(stream_mutex_);
                local_stream = stream_;
            }

            if (local_stream) {
                std::cout << "[Publisher] Provider stream opened" << std::endl;
                // Send ProvideSignalRequest once per signal
                bool need_provide = false;
                {
                    std::lock_guard<std::mutex> lg(stream_mutex_);
                    if (provided_signals_.find(signal_id) == provided_signals_.end()) {
                        need_provide = true;
                    }
                }

                bool provide_ok = true;
                if (need_provide) {
                    kuksa::val::v2::OpenProviderStreamRequest provide_request;
                    auto* provide_signal_request = provide_request.mutable_provide_signal_request();
                    auto& sample_intervals = *provide_signal_request->mutable_signals_sample_intervals();
                    kuksa::val::v2::SampleInterval sample_interval;
                    sample_interval.set_interval_ms(0);
                    sample_intervals[signal_id] = sample_interval;

                    try {
                        if (local_stream->Write(provide_request)) {
                            std::lock_guard<std::mutex> lg(stream_mutex_);
                            provided_signals_.insert(signal_id);
                            std::cerr << "[Publisher] Sent ProvideSignalRequest for id=" << signal_id << std::endl;
                        } else {
                            std::cerr << "[Publisher] Failed to send ProvideSignalRequest for id=" << signal_id << std::endl;
                            provide_ok = false;
                        }
                    } catch (const std::exception& e) {
                        std::cerr << "[Publisher] Exception writing ProvideSignalRequest: " << e.what() << std::endl;
                        provide_ok = false;
                    } catch (...) {
                        std::cerr << "[Publisher] Unknown exception writing ProvideSignalRequest" << std::endl;
                        provide_ok = false;
                    }
                }

                if (provide_ok) {
                    // Build PublishValuesRequest
                    kuksa::val::v2::OpenProviderStreamRequest publish_request;
                    auto* publish_values_request = publish_request.mutable_publish_values_request();
                    publish_values_request->set_request_id(next_request_id_++);

                    kuksa::val::v2::Datapoint data_point;
                    auto now = std::chrono::system_clock::now();
                    auto secs = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
                    auto nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(now.time_since_epoch()).count() - secs * 1000000000LL;
                    google::protobuf::Timestamp* timestamp = data_point.mutable_timestamp();
                    timestamp->set_seconds(secs);
                    timestamp->set_nanos(static_cast<int>(nanos));
                    data_point.mutable_value()->set_float_(value);

                    (*publish_values_request->mutable_data_points())[signal_id] = data_point;

                    try {
                        if (local_stream->Write(publish_request)) {
                            std::cerr << "[Publisher] Sent PublishValuesRequest for id=" << signal_id << std::endl;
                            return true;
                        } else {
                            std::cerr << "[Publisher] Provider stream write failed for " << path << std::endl;
                        }
                    } catch (const std::exception& e) {
                        std::cerr << "[Publisher] Exception writing PublishValuesRequest: " << e.what() << std::endl;
                    } catch (...) {
                        std::cerr << "[Publisher] Unknown exception writing PublishValuesRequest" << std::endl;
                    }
                }

                // Stream write failed: reset so EnsureProviderStream() creates a fresh one
                // on the next call. local_stream still holds a ref keeping the object alive.
                ResetProviderStream();
            }
        }
    }

    // Fallback: unary PublishValue
    grpc::ClientContext context;
    AttachAuth(context);
    val::v2::PublishValueRequest request;
    val::v2::PublishValueResponse response;

    request.mutable_signal_id()->set_path(path);
    request.mutable_data_point()->mutable_value()->set_float_(value);

    grpc::Status status = stub_->PublishValue(&context, request, &response);
    
    if (!status.ok()) {
        std::cerr << "[Publisher] PublishValue(" << path << ", " << value
                  << ") failed: code=" << status.error_code()
                  << " msg='" << status.error_message() << "'" << std::endl;
        return false;
    }
    
    return true;
}

bool Publisher::PublishInt32(const std::string& path, int32_t value) {
    grpc::ClientContext context;
    AttachAuth(context);
    val::v2::PublishValueRequest request;
    val::v2::PublishValueResponse response;

    request.mutable_signal_id()->set_path(path);
    request.mutable_data_point()->mutable_value()->set_int32(value);

    grpc::Status status = stub_->PublishValue(&context, request, &response);
    
    if (!status.ok()) {
        std::cerr << "[Publisher] PublishValue(" << path << ", " << value
                  << ") failed: code=" << status.error_code()
                  << " msg='" << status.error_message() << "'" << std::endl;
        return false;
    }
    
    return true;
}

bool Publisher::PublishUint32(const std::string& path, uint32_t value) {
    grpc::ClientContext context;
    AttachAuth(context);
    val::v2::PublishValueRequest request;
    val::v2::PublishValueResponse response;

    request.mutable_signal_id()->set_path(path);
    request.mutable_data_point()->mutable_value()->set_uint32(value);

    grpc::Status status = stub_->PublishValue(&context, request, &response);
    
    if (!status.ok()) {
        std::cerr << "[Publisher] PublishValue(" << path << ", " << value 
                  << ") failed: " << status.error_message() << std::endl;
        return false;
    }
    
    return true;
}

bool Publisher::PublishBool(const std::string& path, bool value) {
    grpc::ClientContext context;
    AttachAuth(context);
    val::v2::PublishValueRequest request;
    val::v2::PublishValueResponse response;

    request.mutable_signal_id()->set_path(path);
    request.mutable_data_point()->mutable_value()->set_bool_(value);

    grpc::Status status = stub_->PublishValue(&context, request, &response);
    
    if (!status.ok()) {
        std::cerr << "[Publisher] PublishValue(" << path << ", " << (value ? "true" : "false")
                  << ") failed: code=" << status.error_code()
                  << " msg='" << status.error_message() << "'" << std::endl;
        return false;
    }
    
    return true;
}

bool Publisher::PublishString(const std::string& path, const std::string& value) {
    grpc::ClientContext context;
    AttachAuth(context);
    val::v2::PublishValueRequest request;
    val::v2::PublishValueResponse response;

    request.mutable_signal_id()->set_path(path);
    request.mutable_data_point()->mutable_value()->set_string(value);

    grpc::Status status = stub_->PublishValue(&context, request, &response);
    
    if (!status.ok()) {
        std::cerr << "[Publisher] PublishValue(" << path << ", \"" << value
                  << "\") failed: code=" << status.error_code()
                  << " msg='" << status.error_message() << "'" << std::endl;
        return false;
    }
    
    return true;
}

// Tear down the broken provider stream so EnsureProviderStream() rebuilds it next call.
// Safe to call from PublishFloat when a Write() fails: the local_stream shared_ptr copy
// in the caller keeps the gRPC object alive until the function returns.
void Publisher::ResetProviderStream() {
    // Tell the reader thread to stop and unblock its Read() call.
    stream_stop_.store(true);
    if (stream_ctx_) {
        stream_ctx_->TryCancel();
    }
    if (stream_reader_thread_.joinable()) {
        stream_reader_thread_.join();
    }
    // Reset stream state under the lock so EnsureProviderStream() recreates it next call.
    std::lock_guard<std::mutex> lg(stream_mutex_);
    stream_.reset();
    stream_ctx_.reset();
    provided_signals_.clear();
}

// Ensure a provider stream is open and start a reader thread to consume responses
bool Publisher::EnsureProviderStream() {
    std::lock_guard<std::mutex> lg(stream_mutex_);
    if (stream_) return true;

    stream_ctx_ = std::make_unique<grpc::ClientContext>();
    AttachAuth(*stream_ctx_);
    // Open stream as unique_ptr then convert to shared_ptr to allow safe local copies
    auto raw_uptr = stub_->OpenProviderStream(stream_ctx_.get());
    if (!raw_uptr) {
        std::cerr << "[Publisher] Failed to open provider stream" << std::endl;
        stream_ctx_.reset();
        return false;
    }
    stream_ = std::shared_ptr<grpc::ClientReaderWriter<kuksa::val::v2::OpenProviderStreamRequest,
                                                      kuksa::val::v2::OpenProviderStreamResponse>>(raw_uptr.release(), [](auto*p){ delete p; });

    // A bidirectional gRPC stream (ClientReaderWriter) requires the client to consume
    // incoming server messages. Without a reader the server-side write buffer fills up,
    // triggering HTTP/2 flow-control back-pressure that will eventually stall our writes.
    stream_stop_.store(false);
    auto local_stream = stream_;
    stream_reader_thread_ = std::thread([local_stream, &stop = stream_stop_]() {
        kuksa::val::v2::OpenProviderStreamResponse response;
        while (!stop.load() && local_stream && local_stream->Read(&response)) {
            // Drain server acks / error responses — no processing required.
        }
    });

    return true;
}

int32_t Publisher::LookupSignalId(const std::string& path) {
    // Cache lookup
    auto it = signal_id_cache_.find(path);
    if (it != signal_id_cache_.end()) return it->second;

    // Try ListMetadata with the full path first
    grpc::ClientContext client_context;
    AttachAuth(client_context);
    val::v2::ListMetadataRequest list_metadata_request;
    list_metadata_request.set_root(path);
    val::v2::ListMetadataResponse list_metadata_response;
    grpc::Status status = stub_->ListMetadata(&client_context, list_metadata_request, &list_metadata_response);
    if (status.ok()) {
        for (const auto& md : list_metadata_response.metadata()) {
            if (md.path() == path) {
                signal_id_cache_[path] = md.id();
                return md.id();
            }
        }
        // No exact match at this root level; fall through to parent-branch search below.
        // A substring/contains match is intentionally avoided: "Vehicle.Speed" would
        // incorrectly match "Vehicle.SpeedLimit" and return the wrong signal ID.
    }

    // Try parent branch search
    auto pos = path.rfind('.');
    if (pos != std::string::npos) {
        std::string parent = path.substr(0, pos);
        grpc::ClientContext parent_context;
        AttachAuth(parent_context);
        val::v2::ListMetadataRequest parent_list_metadata_request;
        parent_list_metadata_request.set_root(parent);
        val::v2::ListMetadataResponse parent_list_metadata_response;
        grpc::Status parent_status = stub_->ListMetadata(&parent_context, parent_list_metadata_request, &parent_list_metadata_response);
        if (parent_status.ok()) {
            for (const auto& md : parent_list_metadata_response.metadata()) {
                if (md.path() == path) {
                    signal_id_cache_[path] = md.id();
                    return md.id();
                }
            }
        }
    }

    // Not found
    return -1;
}

void Publisher::AttachAuth(grpc::ClientContext& client_context) {
    if (!options_.token.empty()) {
        client_context.AddMetadata("authorization", std::string("Bearer ") + options_.token);
    }
}

std::string Publisher::LoadFile(const std::string& path) {
    if (path.empty()) return {};
    
    std::ifstream ifs(path, std::ios::in | std::ios::binary);
    if (!ifs) return {};
    
    // Check file size to prevent excessive memory consumption
    ifs.seekg(0, std::ios::end);
    std::streamsize file_size = ifs.tellg();
    const std::streamsize MAX_FILE_SIZE = 10 * 1024 * 1024;  // 10 MB limit for certificates
    
    if (file_size > MAX_FILE_SIZE) {
        std::cerr << "[Publisher] File '" << path << "' exceeds maximum allowed size (" 
                  << file_size << " > " << MAX_FILE_SIZE << " bytes)" << std::endl;
        return {};
    }
    
    ifs.seekg(0, std::ios::beg);
    std::string content((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
    return content;
}

} // namespace feeder
