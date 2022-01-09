data "external" "curlip" {
    program = ["sh", "-c", "echo '{ \"extip\": \"'$(curl -s https://ifconfig.me)'\" }'"]
}