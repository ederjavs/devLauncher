#!/bin/bash

# build_app.sh
# Compila y empaqueta DevLauncher como un macOS App Bundle (.app)

set -e

APP_NAME="DevLauncher"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🔨 Compilando paquete Swift en modo Release..."
swift build -c release --arch arm64 --arch x86_64

echo "📦 Creando estructura del App Bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

echo "🚀 Copiando binario executable..."
# Copiar el binario generado por Swift Build universal o arm64
if [ -f ".build/apple/Products/Release/DevLauncher" ]; then
    cp ".build/apple/Products/Release/DevLauncher" "$MACOS_DIR/$APP_NAME"
elif [ -f "$BUILD_DIR/$APP_NAME" ]; then
    cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
else
    # Si se compiló en ruta genérica
    find .build -name "$APP_NAME" -type f -perm +111 -exec cp {} "$MACOS_DIR/$APP_NAME" \; -quit
fi

echo "📝 Generando Info.plist..."
cat <<EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.eder.DevLauncher</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <string>1</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✍️ Firmando la aplicación localmente (Ad-hoc signing)..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "✅ ¡Listo! ${APP_BUNDLE} creado satisfactoriamente."
echo "👉 Ejecútalo escribiendo: open ${APP_BUNDLE}"
