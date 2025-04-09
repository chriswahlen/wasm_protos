// @ts-check

function SayHelloFromLibrary() {
  console.log("Hello from the library!");
}

class JsLib {
  constructor() {}

  sayHello() {
    console.log("Hello from lib");
  }
}

export { JsLib };