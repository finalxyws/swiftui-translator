# SwiftUI Translator Makefile

.PHONY: build run test clean help

# Default target
help:
	@echo "SwiftUI Translator Build Tool"
	@echo ""
	@echo "Available commands:"
	@echo "  build      - Build the project"
	@echo "  run        - Run GUI application"
	@echo "  test       - Show test information"
	@echo "  clean      - Clean build files"
	@echo "  xcode      - Open project in Xcode"
	@echo "  xcode-build- Build using Xcode"
	@echo "  app-bundle - Create macOS app bundle"
	@echo "  help       - Show this help information"

# Build project
build:
	@echo "📦 Building project..."
	swift build

# Run GUI application
run: build
	@echo "🚀 Starting GUI application..."
	swift run

# Run tests
test: build
	@echo "🧪 Running tests..."
	@echo "Note: Tests are available as TranslatorTest.runTests() method"
	@echo "You can call this method from within the application or in a unit test framework"

# Clean build files
clean:
	@echo "🧹 Cleaning build files..."
	swift package clean
	rm -rf .build

# Check Swift version
check:
	@echo "🔍 Checking environment..."
	@echo "Swift version:"
	@swift --version
	@echo ""
	@echo "macOS version:"
	@sw_vers -productName -productVersion

# Install dependencies
deps:
	@echo "📚 Updating dependencies..."
	swift package update

# Build using Xcode (creates .app bundle)
xcode-build:
	@echo "🍎 Building with Xcode..."
	xcodebuild -project SwiftUITranslator.xcodeproj -scheme SwiftUITranslator -configuration Release

# Create app bundle
app-bundle:
	@echo "📱 Creating app bundle..."
	./build-app.sh

# Open in Xcode
xcode:
	@echo "🛠️ Opening in Xcode..."
	open SwiftUITranslator.xcodeproj
