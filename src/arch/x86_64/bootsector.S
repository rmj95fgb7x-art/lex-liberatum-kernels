      - name: Link boot sector flat binary
        run: objcopy -O binary target/x86_64-unknown-none/release/bootsector.o target/x86_64-unknown-none/release/bootsector.bin
