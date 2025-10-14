import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/admin/home/all_feeds.provider.dart';
import 'package:provider/provider.dart';

import 'package:linkschool/modules/admin/home/portal_news_item.dart';
import 'package:linkschool/modules/student/home/feed_details_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

class AllFeedsScreen extends StatefulWidget {
  const AllFeedsScreen({super.key});

  @override
  State<AllFeedsScreen> createState() => _AllFeedsScreenState();
}

class _AllFeedsScreenState extends State<AllFeedsScreen> {
  late ScrollController _scrollController;
  late TextEditingController _editTitleController;
  late TextEditingController _editContentController;
  int? _editingFeedId;
  Map<String, dynamic>? _editingFeedData;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _editTitleController = TextEditingController();
    _editContentController = TextEditingController();

    // Fetch initial feeds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedsPaginationProvider>(context, listen: false)
          .fetchFeeds(refresh: true);
    });
  }

  void _handleScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider =
          Provider.of<FeedsPaginationProvider>(context, listen: false);
      if (provider.hasNextPage && !provider.isLoadingMore) {
        provider.loadMore();
      }
    }
  }

  void _startEditing(feed) {
    _editTitleController = TextEditingController(text: feed.title ?? '');
    _editContentController = TextEditingController(text: feed.content ?? '');
    
    setState(() {
      _editingFeedId = feed.id;
      _editingFeedData = {
        'title': feed.title ?? '',
        'content': feed.content ?? '',
      };
    });
  }

  void _cancelEditing() {
    _editTitleController.dispose();
    _editContentController.dispose();
    
    setState(() {
      _editingFeedId = null;
      _editingFeedData = null;
    });
  }

  void _saveEditing(feed) async {
    final provider = Provider.of<FeedsPaginationProvider>(context, listen: false);
    
    try {
      final updatedFeed = {
        'id': feed.id,
        'title': _editingFeedData?['title'] ?? '',
        'content': _editingFeedData?['content'] ?? '',
        "author_id": feed.authorId,
        'author_name': feed.authorName,
        'type': feed.type,
        'term': 3, // You might want to get this from user data like in PortalHome
      };
      
      print('Updated Feed Data: $updatedFeed');
      
      // You'll need to add updateFeed method to FeedsPaginationProvider
      await provider.updateFeed(updatedFeed, feed.id.toString());
      
      if (mounted) {
        CustomToaster.toastSuccess(context, 'Updated', 'Feed updated successfully');
        _cancelEditing();
        // Refresh the feeds to show updated data
        provider.fetchFeeds(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to update feed: $e');
        debugPrint('Error updating feed: ${feed.id}, Error: $e');
      }
    }
  }

  Future<void> _confirmDelete(feed) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feed'),
        content: const Text('Are you sure you want to delete this feed post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final provider = Provider.of<FeedsPaginationProvider>(context, listen: false);
      await provider.deleteFeed(feed.id.toString());

      if (mounted) {
        CustomToaster.toastSuccess(context, 'Deleted', 'Feed deleted successfully');
        // Refresh the feeds after deletion
        provider.fetchFeeds(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to delete feed');
      }
    }
  }

  Widget _buildEditForm(feed, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.text2Light.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit ${feed.type == 'announcement' ? 'Announcement' : 'News'}',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.text2Light,
                ),
              ),
              IconButton(
                onPressed: _cancelEditing,
                icon: const Icon(Icons.close, color: AppColors.text5Light),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editTitleController,
            onChanged: (value) {
              setState(() {
                _editingFeedData?['title'] = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: const TextStyle(color: AppColors.text5Light),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editContentController,
            onChanged: (value) {
              setState(() {
                _editingFeedData?['content'] = value;
              });
            },
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Content',
              hintStyle: const TextStyle(color: AppColors.text5Light),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.text5Light),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.text5Light,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveEditing(feed),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text2Light,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _editTitleController.dispose();
    _editContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Feeds',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<FeedsPaginationProvider>(context, listen: false)
              .fetchFeeds(refresh: true);
        },
        child: Container(
          color: Colors.grey[50],
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Consumer<FeedsPaginationProvider>(
              builder: (context, provider, _) {
                // Loading state for initial load
                if (provider.isLoading && provider.feeds.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // No feeds
                if (provider.feeds.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.feed,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No feeds available',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Header with count
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Showing ${provider.feeds.length} feeds',
                        style: AppTextStyles.normal500(
                          fontSize: 14,
                          color: AppColors.text7Light,
                        ),
                      ),
                    ),

                    // Feeds list
                    ...provider.feeds.asMap().entries.map((entry) {
                      final index = entry.key;
                      final feed = entry.value;

                      // If this feed is being edited, show edit form
                      if (_editingFeedId == feed.id) {
                        return _buildEditForm(feed, index);
                      }

                      // Otherwise show normal feed item
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FeedDetailsScreen(
                                      replies: [...feed.replies],
                                      profileImageUrl:
                                          'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                                      name: feed.authorName,
                                      content: feed.content,
                                      interactions: feed.replies.length,
                                      time: feed.createdAt,
                                      parentId: feed.id,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  PortalNewsItem(
                                    profileImageUrl:
                                        'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                                    name: feed.authorName,
                                    newsContent: feed.content,
                                    time: feed.createdAt,
                                    title: feed.title ?? '',
                                    edit: () => _startEditing(feed),
                                    delete: () => _confirmDelete(feed),
                                    comments: feed.replies.length,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),

                    // Loading indicator for more
                    if (provider.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(),
                      ),

                    // No more feeds message
                    if (!provider.hasNextPage && provider.feeds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No more feeds to load',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}