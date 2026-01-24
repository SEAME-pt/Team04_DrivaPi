/**
 * @file publisher.hpp
 * @brief KUKSA VAL v2 publisher client wrapper
 * 
 * Provides typed publish methods for sending VSS signals to KUKSA databroker
 */

#pragma once

#include <memory>
#include <string>
#include <grpcpp/grpcpp.h>
#include "kuksa/val/v2/val.grpc.pb.h"
#include <map>
#include <thread>
#include <mutex>
#include <atomic>
#include <set>

namespace kuksa {

/**
 * @brief Simple KUKSA VAL v2 publisher client
 */
struct PublisherOptions {
    std::string address = "localhost:55555";
    bool use_ssl = false;                 // false = insecure
    std::string root_ca_path;             // optional
    std::string client_cert_path;         // optional (for mTLS)
    std::string client_key_path;          // optional (for mTLS)
    std::string token;                    // optional JWT token ("Bearer <token>")
};

class Publisher {
public:
    /**
     * @brief Construct a publisher connected to the specified databroker
     * @param address Databroker address (e.g., "localhost:55555")
     */
    explicit Publisher(const std::string& address);

    /**
     * @brief Construct with options (TLS and auth)
     */
    explicit Publisher(const PublisherOptions& options);
    ~Publisher();

    /**
     * @brief Publish a double value to a VSS path
     * @param path VSS signal path (e.g., "Vehicle.Speed")
     * @param value The value to publish
     * @return true if publish succeeded, false otherwise
     */
    bool PublishDouble(const std::string& path, double value);

    /**
     * @brief Publish a float value to a VSS path
     */
    bool PublishFloat(const std::string& path, float value);

    /**
     * @brief Publish an int32 value to a VSS path
     */
    bool PublishInt32(const std::string& path, int32_t value);

    /**
     * @brief Publish a uint32 value to a VSS path
     */
    bool PublishUint32(const std::string& path, uint32_t value);

    /**
     * @brief Publish a boolean value to a VSS path
     */
    bool PublishBool(const std::string& path, bool value);

    /**
     * @brief Publish a string value to a VSS path
     */
    bool PublishString(const std::string& path, const std::string& value);

    // Provider-stream publishing helpers (used internally)
    bool EnsureProviderStream();
    int32_t LookupSignalId(const std::string& path);

private:
    // Attach authorization metadata if token present
    void AttachAuth(grpc::ClientContext& client_context);

    // Load file contents into string (returns empty if path empty or read fails)
    static std::string LoadFile(const std::string& path);

    PublisherOptions options_;
    std::shared_ptr<grpc::Channel> channel_;
    std::unique_ptr<kuksa::val::v2::VAL::Stub> stub_;
    // Provider stream objects
    std::shared_ptr<grpc::ClientReaderWriter<kuksa::val::v2::OpenProviderStreamRequest,
                                              kuksa::val::v2::OpenProviderStreamResponse>> stream_;
    std::unique_ptr<grpc::ClientContext> stream_ctx_;
    std::thread stream_reader_thread_;
    std::mutex stream_mutex_;
    std::atomic<bool> stream_stop_ {false};
    std::atomic<uint32_t> next_request_id_ {1};
    std::map<std::string,int32_t> signal_id_cache_;
    std::set<int32_t> provided_signals_;
};

} // namespace kuksa
