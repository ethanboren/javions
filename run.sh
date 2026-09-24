#!/usr/bin/env bash
# Compile et lance Javions.
# Usage : ./run.sh [fichier_de_messages]
set -euo pipefail
cd "$(dirname "$0")"

FX_VERSION=21.0.9
FX_DIR=".javafx/javafx-sdk-$FX_VERSION"

# Java 21 (sur macOS, trouvé automatiquement)
if [[ -z "${JAVA_HOME:-}" && "$(uname)" == "Darwin" ]]; then
  JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null || true)
fi
JAVA="${JAVA_HOME:+$JAVA_HOME/bin/}java"
JAVAC="${JAVA_HOME:+$JAVA_HOME/bin/}javac"

# JavaFX (téléchargé une seule fois)
if [[ ! -d "$FX_DIR" ]]; then
  case "$(uname -s)-$(uname -m)" in
    Darwin-arm64)  PLATFORM=osx-aarch64 ;;
    Darwin-x86_64) PLATFORM=osx-x64 ;;
    Linux-x86_64)  PLATFORM=linux-x64 ;;
    Linux-aarch64) PLATFORM=linux-aarch64 ;;
    *) echo "Plateforme non supportée : $(uname -s)-$(uname -m)" >&2; exit 1 ;;
  esac
  echo "Téléchargement de JavaFX $FX_VERSION ($PLATFORM)..."
  mkdir -p .javafx
  curl -fL -o .javafx/fx.zip \
    "https://download2.gluonhq.com/openjfx/$FX_VERSION/openjfx-${FX_VERSION}_${PLATFORM}_bin-sdk.zip"
  unzip -q .javafx/fx.zip -d .javafx && rm .javafx/fx.zip
fi
FX="$FX_DIR/lib"

# Compilation
rm -rf out
"$JAVAC" --module-path "$FX" --add-modules javafx.controls -d out $(find src -name "*.java")

# Lancement
"$JAVA" --module-path "$FX" --add-modules javafx.controls -cp out:resources \
  ch.epfl.javions.gui.Main "${1:-resources/messages_20230318_0915.bin}"
