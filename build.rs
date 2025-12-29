fn main() {
    println!("cargo:rustc-link-search=native=src/arch/x86_64");
    println!("cargo:rerun-if-changed=src/arch/x86_64/boot.S");
    cc::Build::new()
        .file("src/arch/x86_64/boot.S")
        .compile("boot");
}
