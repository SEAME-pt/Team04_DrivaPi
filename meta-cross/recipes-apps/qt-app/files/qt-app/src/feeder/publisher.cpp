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

namespace kuksa {

Publisher::Publisher(const std::string& address) {
    channel_ = grpc::CreateChannel(address, grpc::InsecureChannelCredentials());
    stub_ = val::v2::VAL::NewStub(channel_);
    std::cout << "[Publisher] Connected to KUKSA databroker at " << address << std::endl;
}

Publisher::Publisher(const PublisherOptions& options)
    : options_(options)
{
    std::shared_ptr<grpc::ChannelCredentials> channel_credentials;
    if (!options_.use_ssl) {
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
                stream_stop_.store(false);
                std::cout << "[Publisher] Provider stream opened" << std::endl;
                // Send ProvideSignalRequest once per signal
                bool need_provide = false;
                {
                    std::lock_guard<std::mutex> lg(stream_mutex_);
                    if (provided_signals_.find(signal_id) == provided_signals_.end()) {
                        need_provide = true;
                    }
                }
                if (need_provide) {
                    kuksa::val::v2::OpenProviderStreamRequest provide_request;
                    auto* provide_signal_request = provide_request.mutable_provide_signal_request();
                    auto& sample_intervals = *provide_signal_request->mutable_signals_sample_intervals();
                    kuksa::val::v2::SampleInterval sample_interval;
                    sample_interval.set_interval_ms(0);
                    sample_intervals[signal_id] = sample_interval;

                    try {
                        if (!local_stream->Write(provide_request)) {
                            std::cerr << "[Publisher] Failed to send ProvideSignalRequest for id=" << signal_id << std::endl;
                        } else {
                            std::lock_guard<std::mutex> lg(stream_mutex_);
                            provided_signals_.insert(signal_id);
                            std::cerr << "[Publisher] Sent ProvideSignalRequest for id=" << signal_id << std::endl;
                        }
                    } catch (const std::exception& e) {
                        std::cerr << "[Publisher] Exception writing ProvideSignalRequest: " << e.what() << std::endl;
                    } catch (...) {
                        std::cerr << "[Publisher] Unknown exception writing ProvideSignalRequest" << std::endl;
                    }
                }

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
                        // fallthrough to unary fallback
                    }
                } catch (const std::exception& e) {
                    std::cerr << "[Publisher] Exception writing PublishValuesRequest: " << e.what() << std::endl;
                } catch (...) {
                    std::cerr << "[Publisher] Unknown exception writing PublishValuesRequest" << std::endl;
                }
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

    // No reader thread: we perform writes only and rely on permissive server behavior
    stream_stop_.store(false);

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
        // If exact match not found, try to find an entry that equals the path
        for (const auto& md : list_metadata_response.metadata()) {
            if (md.path().size() >= path.size() && md.path().find(path) != std::string::npos) {
                signal_id_cache_[path] = md.id();
                return md.id();
            }
        }
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

} // namespace kuksa
