use wasm_bindgen::prelude::*;
// use trdl::RailNetwork;

// This function will be callable from JavaScript
#[wasm_bindgen]
pub fn greet() {
    // Log to the browser console
    web_sys::console::log_1(&"Hello, world from Rust!".into());

    // Also, change the document body
    let window = web_sys::window().unwrap();
    let document = window.document().unwrap();
    let body = document.body().unwrap();

    body.set_inner_html("Hello, world from Rust!");
}
