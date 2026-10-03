# gnirsdc-dsp: the GNIRS DC SDSU/ARC timing-board firmware (.lod files),
# assembled from the DSP source in this repo.
#
# %build runs `make firmware`: the Motorola DSP56K assembler, linker and loader
# (compil_DSP56K/, 32-bit Windows console programs) under gemini-wine, which is
# built and published from GitHub like everything else. So the RPM always
# carries firmware assembled from the committed source.
#
# Install path unchanged from the earlier package.

%global specver 0.2.0
# $GIT_HASH first: build_rpm.sh computes it on the host and passes it in.
%define git_hash %(if [ -n "$GIT_HASH" ]; then echo "$GIT_HASH"; else git rev-parse --short HEAD 2>/dev/null || echo nogit; fi)

%global fwdir /gem_base/epics/ioc/%{name}/gnirsdc-firmware

Name:           gnirsdc-dsp
Version:        %{specver}
Release:        1.git%{git_hash}%{?dist}
Summary:        GNIRS DC SDSU/ARC timing-board firmware
License:        Proprietary
Source0:        %{name}-%{version}.tar.gz
# The firmware is architecture-independent; the build needs an x86_64 Wine.
BuildArch:      noarch

BuildRequires:  make
# Pin from the "BUILD DEPENDENCY VERSIONS" block of a green gemini-wine build.
BuildRequires:  gemini-wine = 10.0-1.gite90db7a%{?dist}

%description
Timing-board firmware (.lod) for the GNIRS detector controller's SDSU/ARC
controller, for both the Aladdin II and Aladdin III detector builds, assembled
from the DSP source in this package's repo.

%prep
%setup -q

%build
# clean first: the .lod files in the source tree are replaced by this build's.
make clean
make firmware WINE=/opt/gemini-wine/bin/wine

%install
install -Dpm 0644 FullFrame-unified-AladdinII/AladdinII_SDSU_Firmware.lod \
    %{buildroot}%{fwdir}/AladdinII_SDSU_Firmware.lod
install -Dpm 0644 FullFrame-unified-AladdinIII/AladdinIII_SDSU_Firmware.lod \
    %{buildroot}%{fwdir}/AladdinIII_SDSU_Firmware.lod

%check
# A .lod is a text image whose program memory starts with a _DATA P record.
for f in %{buildroot}%{fwdir}/*.lod; do
    grep -q '^_DATA P' "$f" || { echo "ERROR: $f is not a DSP .lod image" >&2; exit 1; }
done

%files
%dir /gem_base/epics/ioc/%{name}
%{fwdir}

%changelog
* Fri Oct 02 2026 Hawi Stecher <hawi.stecher@noirlab.edu> - 0.2.0-1
- Assemble the firmware in %%build with gemini-wine (Wine 10, WoW64, EL9),
  instead of packaging committed .lod files.

* Fri Oct 02 2026 Hawi Stecher <hawi.stecher@noirlab.edu> - 0.1.0-1
- Build with gemini-rtsw-ci on GitHub. Packages the committed .lod files.
