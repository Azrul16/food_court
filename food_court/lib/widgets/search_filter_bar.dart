import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedCuisine;
  final List<String> cuisines;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCuisineChanged;

  const SearchFilterBar({
    required this.searchQuery,
    required this.selectedCuisine,
    required this.cuisines,
    required this.onSearchChanged,
    required this.onCuisineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search restaurants or dishes...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCuisine,
                isExpanded: true,
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey[500],
                ),
                dropdownColor: Colors.grey[900],
                items: cuisines.map((cuisine) {
                  return DropdownMenuItem<String>(
                    value: cuisine,
                    child: Text(
                      cuisine,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onCuisineChanged(value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
