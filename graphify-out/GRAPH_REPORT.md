# Graph Report - MobiFund  (2026-06-02)

## Corpus Check
- 72 files · ~129,255 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 759 nodes · 903 edges · 35 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 5 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 37 edges
2. `../theme/app_theme.dart` - 34 edges
3. `package:provider/provider.dart` - 23 edges
4. `../services/app_state.dart` - 23 edges
5. `../models/models.dart` - 17 edges
6. `../widgets/shared_widgets.dart` - 16 edges
7. `package:supabase_flutter/supabase_flutter.dart` - 10 edges
8. `../models/module_models.dart` - 8 edges
9. `Create()` - 6 edges
10. `Destroy()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `wWinMain()` --calls--> `GetCommandLineArguments()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/flutter/generated_plugin_registrant.cc

## Communities

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (47): dart:io, build, _buildAction, _buildSummary, _buildTransactionTile, Column, Container, initState (+39 more)

### Community 1 - "Community 1"
Cohesion: 0.04
Nodes (45): dart:convert, Contribution, copyWith, Expense, fromCode, Organization, OrgMember, OrgModule (+37 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (42): AboutScreen, build, Center, Scaffold, SizedBox, build, _bullet, Padding (+34 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (41): BillingTiersScreen, build, _buildTierCard, Container, Divider, Icon, Scaffold, SizedBox (+33 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (41): billing_tiers_screen.dart, bug_report_screen.dart, help_center_screen.dart, build, _contactRow, Container, Divider, Icon (+33 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (40): AppState, calculateGrowth, Exception, getMemberName, getMemberTotal, hasPermission, isFeatureAllowed, isModuleActive (+32 more)

### Community 6 - "Community 6"
Cohesion: 0.06
Nodes (33): BugReportScreen, _BugReportScreenState, build, _buildInfoCard, Container, Icon, Scaffold, SizedBox (+25 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (30): dart:async, build, _checkAuthAndNavigate, dispose, initState, Scaffold, SizedBox, Spacer (+22 more)

### Community 8 - "Community 8"
Cohesion: 0.07
Nodes (27): build, Container, Exception, _kpiCard, _kpiGrid, PlatformOrgDetailScreen, Scaffold, SizedBox (+19 more)

### Community 9 - "Community 9"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 10 - "Community 10"
Cohesion: 0.07
Nodes (26): _approveLoan, build, Center, Column, _compactStatCard, Container, _emptyState, _FilterBarDelegate (+18 more)

### Community 11 - "Community 11"
Cohesion: 0.08
Nodes (25): build, ChamaApp, Icon, InkWell, MainShell, _MainShellState, MaterialApp, _onCenterTap (+17 more)

### Community 12 - "Community 12"
Cohesion: 0.08
Nodes (25): _analyticsCard, _balanceCard, build, Center, Column, Container, DashboardSkeleton, _emptyState (+17 more)

### Community 13 - "Community 13"
Cohesion: 0.09
Nodes (21): build, Center, Column, _compactStatCard, Container, _contributeDialog, _emptyState, _getCategoryColor (+13 more)

### Community 14 - "Community 14"
Cohesion: 0.09
Nodes (21): build, _buildContributionForm, _buildContributionsList, _buildMembersList, Center, Column, Container, _contribCard (+13 more)

### Community 15 - "Community 15"
Cohesion: 0.1
Nodes (20): build, Container, dispose, Divider, Icon, initState, _loadUserData, Material (+12 more)

### Community 16 - "Community 16"
Cohesion: 0.1
Nodes (19): contributionReceived, _ensureLoaded, Exception, expenseNotification, _formatDate, _formatDateTime, _formatTime, loanApproved (+11 more)

### Community 17 - "Community 17"
Cohesion: 0.11
Nodes (18): _advanceCycleDialog, build, Center, Column, _compactStatCard, Container, _cycleCard, _emptyState (+10 more)

### Community 18 - "Community 18"
Cohesion: 0.11
Nodes (18): AlertDialog, build, _buildEmptyState, _buildSectionHeader, Card, Container, _formatDate, _formatShareCount (+10 more)

### Community 19 - "Community 19"
Cohesion: 0.11
Nodes (16): NotificationService, showError, showInfo, showSnackbar, showSuccess, SizedBox, AppHaptics, AppTheme (+8 more)

### Community 20 - "Community 20"
Cohesion: 0.12
Nodes (16): build, _buildContent, _buildExpenseForm, Column, Container, dispose, DropdownMenuItem, _expenseCard (+8 more)

### Community 21 - "Community 21"
Cohesion: 0.13
Nodes (14): contributions_screen.dart, expenses_screen.dart, goals_screen.dart, build, GridSkeleton, Material, _moduleCard, ModulesHubScreen (+6 more)

### Community 22 - "Community 22"
Cohesion: 0.14
Nodes (13): build, Divider, _logoutAllDevices, PrivacySecurityScreen, _PrivacySecurityScreenState, Scaffold, _sectionTitle, _showActiveSessions (+5 more)

### Community 23 - "Community 23"
Cohesion: 0.15
Nodes (12): AlertDialog, build, dispose, _friendlyAuthError, initState, LoginScreen, _LoginScreenState, _PasswordResetDialog (+4 more)

### Community 24 - "Community 24"
Cohesion: 0.15
Nodes (12): build, _buildContactCard, _buildFaqTile, _buildHero, _buildSectionTitle, Container, HelpCenterScreen, _HelpCenterScreenState (+4 more)

### Community 25 - "Community 25"
Cohesion: 0.15
Nodes (12): ../debug/agent_log.dart, build, Container, Icon, InkWell, OrganizationSwitcher, _orgTile, _showCreateOrgDialog (+4 more)

### Community 26 - "Community 26"
Cohesion: 0.38
Nodes (4): b64ToBytes(), decryptJson(), getAccessToken(), json()

### Community 27 - "Community 27"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 28 - "Community 28"
Cohesion: 0.6
Nodes (3): b64ToBytes(), bytesToB64(), encryptJson()

### Community 29 - "Community 29"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 30 - "Community 30"
Cohesion: 0.67
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 31 - "Community 31"
Cohesion: 0.67
Nodes (2): main, package:flutter_test/flutter_test.dart

### Community 32 - "Community 32"
Cohesion: 0.67
Nodes (1): GeneratedPluginRegistrant

### Community 36 - "Community 36"
Cohesion: 1.0
Nodes (1): agentLog

### Community 37 - "Community 37"
Cohesion: 1.0
Nodes (1): MainActivity

## Knowledge Gaps
- **618 isolated node(s):** `-registerWithRegistry`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `main`, `package:flutter_test/flutter_test.dart`, `ChamaApp` (+613 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 29`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (3 nodes): `GeneratedPluginRegistrant.m`, `GeneratedPluginRegistrant`, `-registerWithRegistry`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (3 nodes): `main`, `package:flutter_test/flutter_test.dart`, `widget_test.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (3 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 36`** (2 nodes): `agentLog`, `agent_log.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 2` to `Community 0`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 14`, `Community 15`, `Community 17`, `Community 18`, `Community 19`, `Community 20`, `Community 21`, `Community 22`, `Community 23`, `Community 24`, `Community 25`?**
  _High betweenness centrality (0.268) - this node is a cross-community bridge._
- **Why does `../theme/app_theme.dart` connect `Community 2` to `Community 0`, `Community 3`, `Community 4`, `Community 6`, `Community 7`, `Community 8`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 14`, `Community 15`, `Community 17`, `Community 18`, `Community 19`, `Community 20`, `Community 21`, `Community 22`, `Community 23`, `Community 24`, `Community 25`?**
  _High betweenness centrality (0.167) - this node is a cross-community bridge._
- **Why does `../models/models.dart` connect `Community 0` to `Community 1`, `Community 3`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 10`, `Community 11`, `Community 14`, `Community 15`, `Community 20`, `Community 21`, `Community 25`?**
  _High betweenness centrality (0.110) - this node is a cross-community bridge._
- **What connects `-registerWithRegistry`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `main` to the rest of the system?**
  _618 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._