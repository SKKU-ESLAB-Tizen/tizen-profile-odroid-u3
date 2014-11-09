Name:		model-config-odroid-u3
Summary:	A Model configuration
Version:	1.0.0
Release:	0
Group:		System/Configuration
License:	Apache License, Version 2.0
BuildArch:	noarch
Source0:	%{name}-%{version}.tar.gz

%description
Model configuration data package

%prep
%setup -q -n %{name}-%{version}

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/etc/config
cp -f model-config.xml %{buildroot}/etc/config/model-config.xml
mkdir -p %{buildroot}/usr/share/license
cp %{_builddir}/%{name}-%{version}/LICENSE.APLv2 %{buildroot}/usr/share/license/%{name}

%files
/usr/share/license/%{name}
/etc/config/model-config.xml
%manifest model-config.manifest
