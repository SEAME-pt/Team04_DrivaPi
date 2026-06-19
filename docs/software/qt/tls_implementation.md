## Generate the CA certificate and private key

---


### Set up CA and Chain of Trust

Certificate Authority (CA) is a trusted organization that validates the identities of entities.
Because our Raspberry is a closed local network, we do not need a public Certificate Authority, so we act as our own CA to sign the subsequent certificates.



First, we need to generate a 2048-bit RSA private key for your Certificate Authority. Whoever holds this key controls the trust of the entire vehicle network:

```shell
openssl genrsa -out ca.key 2048
```


Then, we create a self-signed X.509 public certificate `ca.crt` valid for one year. The `-subj` flag bypasses the interactive prompt and sets the Common Name (CN) to "KUKSA-CA".

```shell
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/CN=KUKSA-CA"
```

---

### Generate Server Certificate

Now, we have to create the cryptographic identity for the KUKSA databroker itself.

First, we generate a private key for the server:

```shell
openssl genrsa -out server.key 2048
```

Next, we create a Certificate Signing Request (CSR) for the server. This is essentially the server asking the CA, "Can you vouch that I am localhost?"
The Common Name (CN) should match the hostname or IP address of the server to avoid SSL/TLS warnings:

```shell
openssl req -new -key server.key -out server.csr -subj "/CN=localhost"
```


Modern TLS clients (like gRPC) require Subject Alternative Names (SANs) to verify IPs and DNS names.
Let's create a text file telling the certificate that `localhost` and `127.0.0.1` are valid addresses for this server, otherwise, Qt app would reject the connection.

```shell
cat > ext.cnf <<EOF
subjectAltName = DNS:localhost,IP:127.0.0.1
EOF
```

Then, we ask our CA to sign the server's CSR, creating a certificate that the server can present to clients. This certificate is valid for one year and includes the SANs defined in `ext.cnf`:

```shell
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -extfile ext.cnf
```

Now we confirm the successful signature:
```
Certificate request self-signature ok
subject=CN=localhost
```


### Client's Identity (Mutual TLS)

Because we are enforcing mTLS, the server demands proof of identity from the client (CAN feeder and Qt app) before allowing them to read/write data.

Let's generate a private key for the client:
```shell
openssl genrsa -out client.key 2048
```

Next, we create a CSR for the client. The Common Name (CN) can be something like "KUKSA-Client" to identify it:

```shell
openssl req -new -key client.key -out client.csr -subj "/CN=KUKSA-Client"
```

Finally, we ask our CA to sign the client's CSR, creating a certificate that the client can present to the server. This certificate is also valid for one year:

```shell
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365
```

This creates a CSR for the client and uses CA to sign it, resulting in client.crt. When the CAN feeder connects, it hands this cert to KUKSA. KUKSA verifies it was signed by the CA, and grants access.
We can confirm the successful signature:
```
Certificate request self-signature ok
subject=CN=KUKSA-Client
```

### System Hardening

To protect the private keys from unauthorized access, we should do a couple of things.

Let's create a system directory and copy all the new Public Key Infrastructure files into it:

```shell
sudo mkdir -p /etc/kuksa
sudo cp ca.crt server.crt server.key client.crt client.key /etc/kuksa/
```

Then, we set strict permissions on the private keys to ensure that only the owner (root) can read them:

```shell
sudo chown -R kuksa:kuksa /etc/kuksa
sudo chmod 600 /etc/kuksa/*.key
sudo chmod 644 /etc/kuksa/*.crt
```


With all the steps completed, we can test the connections:

```shell
kuksa_feeder --tls --ca /etc/kuksa/ca.crt --cert /etc/kuksa/client.crt --key /etc/kuksa/client.key
```

As we can see, it successfully connects with TLS enabled:
[ ](https://i.imgur.com/9n7sXoL.png)