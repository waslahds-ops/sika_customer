import 'package:flutter/material.dart';

/// Country data model
class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

/// Available countries
class Countries {
  static const Country lebanon = Country(
    name: 'Lebanon',
    code: 'LB',
    dialCode: '+961',
    flag: '🇱🇧',
  );

  static const Country saudiArabia = Country(
    name: 'Saudi Arabia',
    code: 'SA',
    dialCode: '+966',
    flag: '🇸🇦',
  );

  static const Country kuwait = Country(
    name: 'Kuwait',
    code: 'KW',
    dialCode: '+965',
    flag: '🇰🇼',
  );

  static const Country bahrain = Country(
    name: 'Bahrain',
    code: 'BH',
    dialCode: '+973',
    flag: '🇧🇭',
  );

  static const Country oman = Country(
    name: 'Oman',
    code: 'OM',
    dialCode: '+968',
    flag: '🇴🇲',
  );

  static const Country jordan = Country(
    name: 'Jordan',
    code: 'JO',
    dialCode: '+962',
    flag: '🇯🇴',
  );

  static const Country egypt = Country(
    name: 'Egypt',
    code: 'EG',
    dialCode: '+20',
    flag: '🇪🇬',
  );

  static const Country turkey = Country(
    name: 'Turkey',
    code: 'TR',
    dialCode: '+90',
    flag: '🇹🇷',
  );

  static const List<Country> all = [
    lebanon,
    saudiArabia,
    kuwait,
    bahrain,
    oman,
    jordan,
    egypt,
    turkey,
  ];

  static Country getByCode(String code) {
    return all.firstWhere(
      (country) => country.code == code,
      orElse: () => lebanon,
    );
  }

  static Country getByDialCode(String dialCode) {
    return all.firstWhere(
      (country) => country.dialCode == dialCode,
      orElse: () => lebanon,
    );
  }
}

/// Country selector widget
class CountrySelector extends StatelessWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;

  const CountrySelector({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCountryPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,

          //? TODO: Localizations
          children: [
            Text(selectedCountry.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              selectedCountry.dialCode,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Country',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Countries.all.length,
                itemBuilder: (context, index) {
                  final country = Countries.all[index];
                  final isSelected = country.code == selectedCountry.code;
                  //? TODO: Localizations

                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(country.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.dialCode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFFF6B35),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedTileColor: const Color(
                      0xFFFF6B35,
                    ).withValues(alpha: 0.1),
                    onTap: () {
                      onCountryChanged(country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
