# Assemble the SDSU/ARC firmware with the DSP56K tools (32-bit Windows console
# programs) under Wine -- gemini-wine, which the spec BuildRequires and the dev
# image contains.
WINE ?= /opt/gemini-wine/bin/wine
export WINEDEBUG ?= -all
# A throwaway Wine prefix inside the checkout, so nothing is written to $HOME.
export WINEPREFIX ?= $(CURDIR)/.wineprefix

LODS = FullFrame-unified-AladdinII/AladdinII_SDSU_Firmware.lod \
       FullFrame-unified-AladdinIII/AladdinIII_SDSU_Firmware.lod

all: firmware

firmware:
	cd FullFrame-unified-AladdinII && $(WINE) cmd.exe /C CompileDSP.bat
	cd FullFrame-unified-AladdinIII && $(WINE) cmd.exe /C CompileDSP.bat
	-$(dir $(WINE))wineserver -k
	@for f in $(LODS); do \
	    grep -q '^_DATA P' $$f || { echo "ERROR: $$f was not produced" >&2; exit 1; }; \
	done

install:

uninstall:

distclean: clean

clean:
	rm -f $(LODS)
	rm -rf .wineprefix

.PHONY: all firmware install uninstall distclean clean
