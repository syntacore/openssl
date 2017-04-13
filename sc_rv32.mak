current--makefile:=$(abspath $(lastword $(MAKEFILE_LIST)))
export RISCV?=/opt/riscv32g
export OPENSSL_SRC_DIR:=$(abspath $(dir $(current--makefile)))
export INSTALLDIR?=$(abspath $(OPENSSL_SRC_DIR)/build-openssl-1.0.2)
export CROSS:=riscv32-unknown-linux-gnu
export TARGETMACH:=prefix=$(CROSS)
export CC:=$(CROSS)-gcc
export LD:=$(CROSS)-ld
export AS:=$(CROSS)-as
export AR:=$(CROSS)-ar
QEMU_PATH ?=/home/tools32i/riscv-qemu/riscv32-linux-user/qemu-riscv32

export PATH:=${INSTALLDIR}/bin:$(PATH):$(RISCV)/bin

.PHONY: all
all: conf build

.PHONY: conf
conf:| $(INSTALLDIR)
	cd $(OPENSSL_SRC_DIR) && \
	./Configure -fPIC -DOPENSSL_NO_HEARTBEATS --openssldir=$(INSTALLDIR) shared os/compiler:$(CROSS)-

.PHONY: build
build:|conf
	$(MAKE) -C $(OPENSSL_SRC_DIR)

.PHONY: install
install:|build
	$(MAKE) -C $(OPENSSL_SRC_DIR) install

apps/openssl:|build
.PHONY: run
run:apps/openssl
	$(QEMU_PATH) -L $(RISCV)/sysroot/ apps/openssl speed aes
	
.PHONY: dump
dump:openssl.dump
openssl.dump:apps/openssl
	$(RISCV)/bin/$(CROSS)-objdump -dS $< > $@ 
	
$(INSTALLDIR):
	mkdir -p $@

.PHONY: clean
clean:
	$(MAKE) -C $(OPENSSL_SRC_DIR) clean

.PHONY: distclean
distclean:
	$(MAKE) -C $(OPENSSL_SRC_DIR) distclean

