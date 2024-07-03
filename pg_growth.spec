Name:pg_growth	
Version:1.0	
Release:1%{?dist}
Summary:Database growth tracking extension for PostgreSQL	

Group:Applications/Databases		
License:PostgreSQL	
URL:localhost		
Source0:pg_growth-1.0.tar.gz	

BuildRequires:postgresql-devel	
Requires:postgresql	

%description
This extension tracks the growth of your PostgreSQL database over time.

%prep
%setup -q

%build
make

%install
make DESTDIR=%{buildroot} install

%files
%doc README.md
%{_libdir}/pgsql/pg_growth.so
%{_datadir}/pgsql/extension/pg_growth.control
%{_datadir}/pgsql/extension/pg_growth--1.0.sql

%changelog
* Fri Jun 14 2024 Muhammad Atho'illah muhammadathoillah62@gmail.com - 1.0-1
- Initial package
