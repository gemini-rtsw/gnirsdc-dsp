# gnirsdc-dsp: the GNIRS DC SDSU/ARC timing-board firmware (.lod files).
#
# Packages the .lod files COMMITTED to this repo; it does not assemble them.
# The Motorola DSP56K assembler runs under gemini-wine, which is not in the
# gemini-rtsw rpm-repo, so CI cannot run it. Rebuild firmware the way this repo
# always has -- `./build-firmware.sh` (or `make firmware`), then commit the
# .lod files -- and CI packages what was committed. See README.
#
# Install path unchanged from the earlier package.

%global specver 0.1.0
# $GIT_HASH first: build_rpm.sh computes it on the host and passes it in.
%define git_hash %(if [ -n "$GIT_HASH" ]; then echo "$GIT_HASH"; else git rev-parse --short HEAD 2>/dev/null || echo nogit; fi)

%global fwdir /gem_base/epics/ioc/%{name}/gnirsdc-firmware

Name:           gnirsdc-dsp
Version:        %{specver}
Release:        1.git%{git_hash}%{?dist}
Summary:        GNIRS DC SDSU/ARC timing-board firmware
License:        Proprietary
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

%description
Timing-board firmware (.lod) for the GNIRS detector controller's SDSU/ARC
controller, for both the Aladdin II and Aladdin III detector builds.

%prep
%setup -q

%install
install -Dpm 0644 FullFrame-unified-AladdinII/AladdinII_SDSU_Firmware.lod \
    %{buildroot}%{fwdir}/AladdinII_SDSU_Firmware.lod
install -Dpm 0644 FullFrame-unified-AladdinIII/AladdinIII_SDSU_Firmware.lod \
    %{buildroot}%{fwdir}/AladdinIII_SDSU_Firmware.lod

%check
# A .lod is a text image whose program memory starts with a _DATA P record;
# catch an empty or truncated commit here rather than at controller init.
for f in %{buildroot}%{fwdir}/*.lod; do
    grep -q '^_DATA P' "$f" || { echo "ERROR: $f is not a DSP .lod image" >&2; exit 1; }
done

%files
%dir /gem_base/epics/ioc/%{name}
%{fwdir}

%changelog
* Fri Oct 02 2026 Hawi Stecher <hawi.stecher@noirlab.edu> - 0.1.0-1
- Build with gemini-rtsw-ci on GitHub. Packages the committed .lod files;
  assembling them needs gemini-wine, which is not in rpm-repo.
