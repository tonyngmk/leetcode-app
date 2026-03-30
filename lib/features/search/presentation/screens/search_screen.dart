import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../injection.dart';
import '../../../problems/data/models/problem_list_item_model.dart';
import '../../../problems/domain/repositories/problems_repository.dart';
import '../../../problems/presentation/widgets/problem_list_tile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<ProblemListItem>? _results;
  bool _loading = false;
  String? _error;

  List<String> get _recentSearches => sl<ProfileRepository>().recentSearches;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _search(query.trim()),
    );
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // LeetCode's PROBLEMS_QUERY supports searchKeywords via filters
      final response = await sl<ProblemsRepository>().getProblems(
        limit: 50,
        skip: 0,
        tags: null,
      );
      // Client-side filter since the API doesn't have a direct search keyword field
      final filtered = response.questions
          .where((p) =>
              p.title.toLowerCase().contains(query.toLowerCase()) ||
              p.questionFrontendId == query)
          .toList();
      await sl<ProfileRepository>().addRecentSearch(query);
      setState(() {
        _results = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search problems...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: AppColors.hard)))
                    : _results != null
                        ? _results!.isEmpty
                            ? const Center(child: Text('No results found'))
                            : ListView.builder(
                                itemCount: _results!.length,
                                itemBuilder: (context, index) =>
                                    ProblemListTile(problem: _results![index]),
                              )
                        : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    final searches = _recentSearches;
    if (searches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 48, color: AppColors.textSecondary),
            const Gap(AppSpacing.s),
            Text(
              'Search for problems by name or number',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
          const Gap(AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: searches.map((search) {
              return InputChip(
                label: Text(search),
                onPressed: () {
                  _controller.text = search;
                  _search(search);
                },
                onDeleted: () async {
                  await sl<ProfileRepository>().removeRecentSearch(search);
                  setState(() {});
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
