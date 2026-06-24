import 'package:flutter/material.dart';
import '../data/countries.dart';

/// Widget pour sélectionner un pays avec recherche
class CountryPicker extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final bool showDialCode;
  final bool showFlag;

  const CountryPicker({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.showDialCode = true,
    this.showFlag = true,
  });

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCountryPickerDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showFlag) ...[
              Text(
                widget.selectedCountry.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.showDialCode)
              Text(
                widget.selectedCountry.dialCode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerBottomSheet(
        selectedCountry: widget.selectedCountry,
        onCountrySelected: (country) {
          widget.onCountryChanged(country);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CountryPickerBottomSheet extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const _CountryPickerBottomSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<_CountryPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = countries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCountries = searchCountries(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sélectionner un pays',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un pays...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Country list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country.code == widget.selectedCountry.code;
                
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(country.dialCode),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFFE65100))
                      : null,
                  onTap: () => widget.onCountrySelected(country),
                  selected: isSelected,
                  selectedTileColor: const Color(0xFFE65100).withOpacity(0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compact pour afficher le sélecteur de pays à côté du champ téléphone
class CountryCodeSelector extends StatelessWidget {
  final Country selectedCountry;
  final VoidCallback onTap;

  const CountryCodeSelector({
    super.key,
    required this.selectedCountry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCountry.dialCode,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
