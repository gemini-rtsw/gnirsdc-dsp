all:
	make firmware

firmware:
	cd FullFrame-unified-AladdinII && WINEDEBUG=-all /gem_base/epics/ioc/gemini-wine/wine-7.0/wine cmd.exe \nogui /C CompileDSP.bat
	cd FullFrame-unified-AladdinIII && WINEDEBUG=-all /gem_base/epics/ioc/gemini-wine/wine-7.0/wine cmd.exe \nogui /C CompileDSP.bat

install:

uninstall:

distclean:
	make clean

clean:
	rm FullFrame-unified-AladdinII/*.lod
	rm FullFrame-unified-AladdinIII/*.lod
