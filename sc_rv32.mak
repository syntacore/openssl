export OPENSSL_SRC_DIR:=$(realpath .)
export INSTALLDIR:=$(abspath ../build-openssl-1.0.2)
export CROSS:=riscv32-unknown-linux-gnu
export TARGETMACH:=prefix=$(CROSS)
export CC:=$(CROSS)-gcc
export LD:=$(CROSS)-ld
export AS:=$(CROSS)-as
export AR:=$(CROSS)-ar
QEMU_PATH ?=/home/tools32i/riscv-qemu/riscv32-linux-user/qemu-riscv32

export PATH:=${INSTALLDIR}/bin:$(PATH):$(RISCV)/bin

all: conf build
.PHONY: all

$(INSTALLDIR):
	mkdir -p $@

conf:| $(INSTALLDIR)
	cd $(OPENSSL_SRC_DIR) && \
	./Configure -fPIC -DOPENSSL_NO_HEARTBEATS --openssldir=$(INSTALLDIR) shared os/compiler:$(CROSS)-
.PHONY: conf

.PHONY: build
build:|conf
	$(MAKE) -C $(OPENSSL_SRC_DIR)

.PHONY: install
install:|build
	$(MAKE) -C $(OPENSSL_SRC_DIR) install

.PHONY: run
run:
	$(QEMU_PATH) -L /opt/riscv32g/sysroot/ $(INSTALLDIR)/bin/openssl speed aes
	
.PHONY: dump
dump:
	/opt/riscv32g/bin/riscv32-unknown-linux-gnu-objdump -dS $(INSTALLDIR)/bin/openssl >openssl.dump 
	
.PHONY: clean
clean:
	$(MAKE) -C $(OPENSSL_SRC_DIR) clean

.PHONY: distclean
distclean:
	$(MAKE) -C $(OPENSSL_SRC_DIR) distclean

