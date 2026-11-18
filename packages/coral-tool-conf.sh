package: coral-tool-conf
version: vCMS
requires:
 - coral-tools
---
# =============================================================================
# coral-tool-conf: Deploys tool configuration files from coral-tools templates
# =============================================================================
# This script takes the embedded XML templates created by coral-tools and
# expands them into actual XML tool configuration files for SCRAM.
#
# Flow:
#   coral-tools creates .tmpl files (XML embedded in heredocs)
#       -> this script expands paths via envsubst
#       -> executes templates to produce final XML files
# =============================================================================

# Create the directory structure for tool configurations
# - selected/  : tools that are actively used in the build
# - available/ : tools that exist but are not currently selected
mkdir -p $INSTALLROOT/tools/{available,selected}

# Copy shared libraries from coral-tools installation
# These libs are needed by the tools at runtime
rsync -a $CORAL_TOOLS_ROOT/lib $INSTALLROOT/

# Set PKGINSTROOT to the current package's install location
# This variable gets substituted into the template files to create
# absolute paths in the final XML tool configurations
export PKGINSTROOT=$INSTALLROOT

# -----------------------------------------------------------------------------
# Process "selected" tools (actively used tools)
# -----------------------------------------------------------------------------
# 1. Use envsubst to replace $PKGINSTROOT with actual path in the template
# 2. The template contains heredocs that write XML files when executed
envsubst '$PKGINSTROOT' < $CORAL_TOOLS_ROOT/tools/selected.tmpl > $INSTALLROOT/tools/template.tmpl

# Execute the processed template - this runs the heredocs which create
# individual XML files in $INSTALLROOT/tools/selected/
bash $INSTALLROOT/tools/template.tmpl

# -----------------------------------------------------------------------------
# Process "available" tools (optional/inactive tools)
# -----------------------------------------------------------------------------
# Same process for available tools
envsubst '$PKGINSTROOT' < $CORAL_TOOLS_ROOT/tools/available.tmpl > $INSTALLROOT/tools/template.tmpl

# Execute to create XML files in $INSTALLROOT/tools/available/
bash $INSTALLROOT/tools/template.tmpl
