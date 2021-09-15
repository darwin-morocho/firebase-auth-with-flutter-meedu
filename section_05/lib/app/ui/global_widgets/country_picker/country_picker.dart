import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_firebase_auth/app/domain/models/country.dart';
import 'package:flutter_firebase_auth/app/ui/utils/countries.dart';
import 'package:flutter_meedu/router.dart' as router;

final List<Country> countries = countriesData
    .map(
      (e) => Country.fromJson(e),
    )
    .toList();

Future<Country?> showCountryPicker() {
  return router.push<Country>(
    const CountryPicker(),
    transition: router.Transition.downToUp,
  );
}

class CountryPicker extends StatefulWidget {
  const CountryPicker({Key? key}) : super(key: key);

  @override
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  final ValueNotifier<String> _query = ValueNotifier("");
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CountryPickerAppBar(
        child: TextField(
          focusNode: _searchFocus,
          controller: _searchController,
          onChanged: (text) => _query.value = text,
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            hintText: "Search...",
            suffixIcon: ValueListenableBuilder<String>(
              valueListenable: _query,
              builder: (_, query, __) {
                if (query.isEmpty) {
                  return const SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
                return IconButton(
                  onPressed: () {
                    _searchController.text = "";
                    _searchFocus.unfocus();
                    _query.value = "";
                  },
                  icon: const Icon(Icons.cancel_rounded),
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<String>(
          valueListenable: _query,
          builder: (_, query, __) {
            late List<Country> filteredList;
            if (query.trim().isNotEmpty) {
              filteredList = countries
                  .where(
                    (e) => e.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
                  )
                  .toList();
            } else {
              filteredList = countries;
            }

            return ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (_, index) {
                final country = filteredList[index];
                return ListTile(
                  leading: Image.network(
                    country.flag,
                    width: 40,
                  ),
                  title: Text(country.name),
                  subtitle: Text("${country.dialCode} - ${country.code}"),
                  onTap: () {
                    Navigator.pop(context, country);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CountryPickerAppBar extends StatelessWidget with PreferredSizeWidget {
  final Widget child;
  const _CountryPickerAppBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xfffafafa),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 30,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 30),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
        kToolbarHeight,
      );
}
