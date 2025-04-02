This is a bare minimum project to interface C++ via WASM with javascript
using entirely ES6-style bindings.

# Build With:

```
bazelisk build //web:web_protos
bazelisk build //main:hello-world-wasm
```

# Test with:
```
./start-webserver.sh
```

NOTE: web_protos doesn't get automatically rebuilt.
