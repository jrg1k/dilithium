use std::path::PathBuf;

fn main() {
    let cfiles = [
        "ntt.c",
        "packing.c",
        "poly.c",
        "polyvec.c",
        "reduce.c",
        "rounding.c",
        "sign.c",
        "symmetric-shake.c",
    ];

    cc::Build::new()
        .file("ref/fips202.c")
        .flag("-fomit-frame-pointer")
        .compile("fips202");

    let out_path = PathBuf::from(std::env::var("OUT_DIR").unwrap());
    let prefix = PathBuf::from("ref");
    for mode in ["2", "3", "5"] {
        let name = format!("dilithium{}", mode);
        cc::Build::new()
            .files(cfiles.map(|f| prefix.join(f)))
            .warnings(true)
            .extra_warnings(true)
            .warnings_into_errors(true)
            .flag("-fomit-frame-pointer")
            .pic(false)
            .define("DILITHIUM_MODE", mode)
            .compile(&name);

        let bindings = bindgen::builder()
            .headers(["ref/sign.h"])
            .clang_arg(format!("-DDILITHIUM_MODE={}", mode))
            .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
            .use_core()
            .generate()
            .expect("failed to generate bindings");

        bindings
            .write_to_file(out_path.join(format!("dilithium{}_bindings.rs", mode)))
            .expect("Couldn't write bindings!");
    }

    println!("cargo:rerun-if-changed=ref");
}
