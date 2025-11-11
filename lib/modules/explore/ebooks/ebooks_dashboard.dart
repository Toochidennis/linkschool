import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/home/ebook_provider.dart';
import 'package:provider/provider.dart';
// import 'ebook_provider.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../e_library/e_library_ebooks/book_page.dart';
import 'all_tab.dart';
import 'books_button_item.dart';

class EbooksDashboard extends StatefulWidget {
  const EbooksDashboard({super.key});

  @override
  State<EbooksDashboard> createState() => _EbooksDashboardState();
}

class _EbooksDashboardState extends State<EbooksDashboard> {
  int _selectedBookCategoriesIndex = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch books data when the widget is initialized
    final bookProvider = Provider.of<EbookProvider>(context, listen: false);
    bookProvider.fetchBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<EbookProvider>(context);
    final categories = bookProvider.categories;

    return Scaffold(
      appBar: Constants.customAppBar(context: context, showBackButton: true),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: bookProvider.isLoading || categories.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.text2Light,
                  strokeWidth: 3.0,
                ),
              )
            : Stack(
                children: [
                  _buildTabController(categories),
                  if (_isSearching) _buildSearchResults(bookProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildTabController(List<String> categories) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'What do you want to\nread today?',
                        style: AppTextStyles.normal600(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildSearchBar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: List.generate(categories.length, (index) {
                          return BooksButtonItem(
                            label: categories[index].toUpperCase(),
                            isSelected: _selectedBookCategoriesIndex == index,
                            onPressed: () {
                              setState(() {
                                _selectedBookCategoriesIndex = index;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                unselectedLabelColor: const Color.fromRGBO(90, 90, 90, 1),
                labelColor: AppColors.text2Light,
                labelStyle: AppTextStyles.normal600(
                  fontSize: 16.0,
                  color: AppColors.text2Light,
                ),
                indicatorColor: AppColors.text2Light,
                tabs: const [Tab(text: 'All'), Tab(text: 'Library')],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            AllTab(selectedCategoryIndex: _selectedBookCategoriesIndex),
            Container(
              color: Colors.orange,
              child: const Center(
                child: Text('Tab 2'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 50,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            labelText: 'Search',
            labelStyle: AppTextStyles.normal500(
              fontSize: 14.0,
              color: AppColors.text10Light,
            ),
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(24.0),
              ),
              gapPadding: 4.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(EbookProvider bookProvider) {
    // Filter books based on search query
    final searchResults = bookProvider.ebooks.where((book) {
      return book.title.toLowerCase().contains(_searchQuery) ||
          book.author.toLowerCase().contains(_searchQuery) ||
          book.categories.any((cat) => cat.toLowerCase().contains(_searchQuery));
    }).toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search bar area (to maintain spacing)
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'What do you want to\nread today?',
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildSearchBar(),
              ],
            ),
          ),
          // Search results header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Results',
                  style: AppTextStyles.normal600(
                    fontSize: 18.0,
                    color: AppColors.text2Light,
                  ),
                ),
                Text(
                  '${searchResults.length} found',
                  style: AppTextStyles.normal500(
                    fontSize: 14.0,
                    color: AppColors.text5Light,
                  ),
                ),
              ],
            ),
          ),
          // Search results list
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.text5Light,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: AppTextStyles.normal500(
                            fontSize: 16.0,
                            color: AppColors.text5Light,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      final book = searchResults[index];
                      return _buildSearchResultItem(book);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to book details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MybookPage(suggestedbook: book),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Image.network(
                  book.thumbnail,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 90,
                      color: AppColors.text6Light,
                      child: const Icon(Icons.book),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: AppTextStyles.normal500(
                        fontSize: 14.0,
                        color: AppColors.text5Light,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: book.categories.take(3).map<Widget>((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgXplore3.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            category,
                            style: AppTextStyles.normal500(
                              fontSize: 12.0,
                              color: AppColors.text2Light,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.text5Light,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
