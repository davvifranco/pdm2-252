import 'package:flutter/material.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GitHubSummary extends StatefulWidget {
  const GitHubSummary({required this.gitHub, super.key});
  final GitHub gitHub;

  @override
  State<GitHubSummary> createState() => _GitHubSummaryState();
}

class _GitHubSummaryState extends State<GitHubSummary> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Octicons.repo),
              label: Text('Repositories'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.issue_opened),
              label: Text('Assigned Issues'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.git_pull_request),
              label: Text('Pull Requests'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              RepositoriesList(gitHub: widget.gitHub),
              AssignedIssuesList(gitHub: widget.gitHub),
              PullRequestsList(gitHub: widget.gitHub),
            ],
          ),
        ),
      ],
    );
  }
}

// =================== RepositoriesList ===================
class RepositoriesList extends StatefulWidget {
  const RepositoriesList({required this.gitHub, super.key});
  final GitHub gitHub;

  @override
  State<RepositoriesList> createState() => _RepositoriesListState();
}

class _RepositoriesListState extends State<RepositoriesList> {
  late Future<List<Repository>> _repositories;

  @override
  void initState() {
    super.initState();
    _repositories = widget.gitHub.repositories.listRepositories().toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Repository>>(
      future: _repositories,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        var repositories = snapshot.data!;
        return ListView.builder(
          itemCount: repositories.length,
          itemBuilder: (context, index) {
            var repository = repositories[index];
            return ListTile(
              title: Text(
                '${repository.owner?.login ?? ''}/${repository.name}',
              ),
              subtitle: Text(repository.description ?? ''),
              onTap: () => _launchUrl(context, repository.htmlUrl),
            );
          },
        );
      },
    );
  }
}

// =================== AssignedIssuesList ===================
class AssignedIssuesList extends StatefulWidget {
  const AssignedIssuesList({required this.gitHub, super.key});
  final GitHub gitHub;

  @override
  State<AssignedIssuesList> createState() => _AssignedIssuesListState();
}

class _AssignedIssuesListState extends State<AssignedIssuesList> {
  late Future<List<Issue>> _assignedIssues;

  @override
  void initState() {
    super.initState();
    _assignedIssues = widget.gitHub.issues.listByUser().toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Issue>>(
      future: _assignedIssues,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        var issues = snapshot.data!;
        return ListView.builder(
          itemCount: issues.length,
          itemBuilder: (context, index) {
            var issue = issues[index];
            return ListTile(
              title: Text(issue.title),
              subtitle: Text(
                '${_nameWithOwner(issue)} Issue #${issue.number} opened by ${issue.user?.login ?? ''}',
              ),
              onTap: () => _launchUrl(context, issue.htmlUrl),
            );
          },
        );
      },
    );
  }

  String _nameWithOwner(Issue issue) {
    final endIndex = issue.url.lastIndexOf('/issues/');
    return issue.url.substring(29, endIndex);
  }
}

// =================== PullRequestsList ===================
class PullRequestsList extends StatefulWidget {
  const PullRequestsList({required this.gitHub, super.key});
  final GitHub gitHub;

  @override
  State<PullRequestsList> createState() => _PullRequestsListState();
}

class _PullRequestsListState extends State<PullRequestsList> {
  late Future<List<PullRequest>> _pullRequests;

  @override
  void initState() {
    super.initState();
    _pullRequests = widget.gitHub.pullRequests
        .list(RepositorySlug('flutter', 'flutter'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PullRequest>>(
      future: _pullRequests,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        var prs = snapshot.data!;
        return ListView.builder(
          itemCount: prs.length,
          itemBuilder: (context, index) {
            var pr = prs[index];
            return ListTile(
              title: Text(pr.title ?? ''),
              subtitle: Text(
                'flutter/flutter PR #${pr.number} opened by ${pr.user?.login ?? ''} (${pr.state?.toLowerCase() ?? ''})',
              ),
              onTap: () => _launchUrl(context, pr.htmlUrl ?? ''),
            );
          },
        );
      },
    );
  }
}

// =================== Função de abrir URL ===================
Future<void> _launchUrl(BuildContext context, String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation error'),
        content: Text('Could not launch $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
