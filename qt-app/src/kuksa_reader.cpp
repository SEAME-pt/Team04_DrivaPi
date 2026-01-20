#include "kuksa_reader.hpp"
//QDateTime for latency testing - remove later
#include <QDateTime>

KUKSAReader::KUKSAReader(QObject *parent)
    : QObject(parent)
{}

KUKSAReader::~KUKSAReader()
{}

void KUKSAReader::start()
{
    //1. Connect to Broker auto channel
    auto channel = grpc::CreateChannel("localhost:55555", grpc::InsecureChannelCredentials());
    m_stub_ = VAL::NewStub(channel);

    //2. Subscribe to speed data
    grpc::ClientContext context;
    SubscribeRequest request;

    auto *entry = request.add_entries();
    entry->set_path("Vehicle.Speed");
    entry->add_fields(Field::FIELD_VALUE);

    std::unique_ptr<grpc::ClientReader<SubscribeResponse>> reader(
        m_stub_->Subscribe(&context, request));

    SubscribeResponse response;
    qDebug() << "KuksaReader: Connected and Subscribed to Vehicle.Speed";

    //3. Loop to read incoming speed data (blocking call so run in separate thread (QThread))
    while(reader->Read(&response))
    {
        for (const auto &update : response.updates())
        {
                if (update.entry().path() == "Vehicle.Speed")
                {
                    float speed = update.entry().value().float_();
                    
                    //LATENCY TESTING CODE - REMOVE LATER
                    auto now = std::chrono::steady_clock::now();
                    long long t_ns = std::chrono::duration_cast<std::chrono::nanoseconds>(now.time_since_epoch()).count();
                    double t1 = static_cast<double>(t_ns) / 1e9;
                    std::cout << "KuksaReader: Received speed: " << speed << " at " << std::fixed << std::setprecision(6) << t1 << std::endl;
                    //END LATENCY TESTING CODE

                    emit speedReceived(speed);
                }
        }
    }
}

