#!/bin/bash

# SPOTS Workspace Cleanup Preview Script
# Shows what would be deleted WITHOUT actually deleting anything
# Date: July 30, 2025

echo "🔍 Previewing SPOTS workspace cleanup..."
echo "⚠️  This is a DRY RUN - nothing will be deleted!"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to preview what would be removed
preview_remove() {
    local path="$1"
    local description="$2"
    
    if [ -e "$path" ]; then
        echo -e "${YELLOW}🗑️  WOULD REMOVE $description: $path${NC}"
        # Show file size and type
        if [ -f "$path" ]; then
            echo -e "${BLUE}   📄 File size: $(du -h "$path" | cut -f1)${NC}"
        elif [ -d "$path" ]; then
            echo -e "${BLUE}   📁 Directory with $(find "$path" -type f | wc -l) files${NC}"
        fi
    else
        echo -e "${BLUE}✅ Already clean: $path${NC}"
    fi
}

echo -e "${CYAN}📋 Previewing cleanup operations...${NC}"
echo ""

# ===== BACKGROUND AGENT FILES =====
echo -e "${CYAN}🔧 Background Agent Files:${NC}"

preview_remove "background_agent/" "Background agent directory"
preview_remove "analysis_*.log" "Analysis log files"
preview_remove "session_report_*.md" "Session reports"
preview_remove "backup_before_fixes_*/" "Backup directories"
preview_remove "spots_data_export/" "Data export directory"
preview_remove "*.db" "Database files"
preview_remove "auto_*.sh" "Auto-generated scripts"
preview_remove "*_GUIDE.md" "Guide files"
preview_remove "*_REPORT.md" "Report files"
preview_remove "MVP_ROADMAP.md" "MVP roadmap"
preview_remove "analysis_options.yaml" "Analysis options"

echo ""

# ===== DEVELOPMENT FILES =====
echo -e "${CYAN}💻 Development Files:${NC}"

preview_remove ".vscode/" "VS Code directory"
preview_remove ".idea/" "IntelliJ directory"
preview_remove ".cursor/" "Cursor directory"
preview_remove ".DS_Store" "macOS DS Store"
preview_remove "coverage/" "Coverage directory"
preview_remove "*.tmp" "Temporary files"
preview_remove "*.cache" "Cache files"

echo ""

# ===== SENSITIVE FILES =====
echo -e "${CYAN}🔒 Sensitive Files (would be protected):${NC}"

preview_remove ".env" "Environment file"
preview_remove "secrets.dart" "Secrets file"
preview_remove "google-services.json" "Google services config"
preview_remove "*.p12" "Certificate files"

echo ""

# ===== IMPORTANT FILES (SHOULD NOT BE DELETED) =====
echo -e "${GREEN}✅ Important Files (SAFE - would NOT be deleted):${NC}"

echo -e "${GREEN}   📁 lib/ - Your source code${NC}"
echo -e "${GREEN}   📁 test/ - Your test files${NC}"
echo -e "${GREEN}   📁 android/ - Android configuration${NC}"
echo -e "${GREEN}   📁 ios/ - iOS configuration${NC}"
echo -e "${GREEN}   📄 pubspec.yaml - Dependencies${NC}"
echo -e "${GREEN}   📄 README.md - Project documentation${NC}"
echo -e "${GREEN}   📄 .gitignore - Git ignore rules${NC}"

echo ""
echo -e "${CYAN}📊 Summary:${NC}"
echo "  - Files marked with 🗑️  would be deleted"
echo "  - Files marked with ✅ are already clean"
echo "  - Files marked with 🔒 are sensitive and protected"
echo "  - Files marked with 📁 are important and safe"
echo ""
echo -e "${YELLOW}💡 To actually run the cleanup:${NC}"
echo "  ./clean_workspace.sh"
echo ""
echo -e "${GREEN}✅ Preview complete - no files were deleted!${NC}" 