#include <iostream>

#include <emscripten.h>
#include "main/proto/hello.pb.h"
#include "main/proto/goodbye.pb.h"

extern "C" {
  // The simplest possible function.
  void say_hello() {
    std::cout << "Hello from C++!" << std::endl;
  }

  // A basic proto-in, proto-out function.
  // Returns a malloc'd pointer, so the caller is responsible for freeing it.
  EMSCRIPTEN_KEEPALIVE
  uint8_t* handle_greeting(uint8_t* data, int in_len, int* out_len) {
    hello::HelloProto helloMsg;
    if (helloMsg.ParseFromArray(data, in_len)) {
      std::cout << "From JS: " << helloMsg.greeting() << std::endl;
    } else {
      std::cerr << "Failed to parse message from JS" << std::endl;
    }

    hello::GoodbyeProto goodbyeMsg;
    goodbyeMsg.set_adios("Goodbye from C++!");
    static std::string serialized;
    serialized = goodbyeMsg.SerializeAsString();
    *out_len = serialized.size();

    uint8_t* buffer = (uint8_t*)malloc(serialized.size());
    memcpy(buffer, serialized.data(), serialized.size());
    return buffer;
  }
}

// This gets run on page load.
int main() {
  std::cout << "WASM initialized!" << std::endl;
  return 0;
}
