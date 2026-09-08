# Maintainer: CedricXBG cedricxbg@icloud.com
pkgname=steam-shortcut-creator
pkgver=1.1.0
pkgrel=1
pkgdesc="A lightweight GTK3/x86_64 Assembly utility to generate Steam .desktop shortcuts."
arch=('x86_64')
url="https://github.com/CedricXBG/steam-shortcut-creator"
license=('MIT')
depends=('gtk3' 'curl')
makedepends=('nasm' 'binutils' 'make' 'git')
source=("git+https://github.com/CedricXBG/steam-shortcut-creator.git")
sha256sums=('SKIP')

build() {
	cd "$pkgname"
	make
}

package() {
	cd "$pkgname"
	# Binary installation in /usr/bin
	install -Dm755 build/steam-shortcut-creator "$pkgdir/usr/bin/steam-shortcut-creator"
	# License installation
	install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
