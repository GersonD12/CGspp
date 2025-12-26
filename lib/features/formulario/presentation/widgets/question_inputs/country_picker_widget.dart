import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

/// Widget para seleccionar un país
class CountryPickerWidget extends StatefulWidget {
  /// El texto que se muestra como título
  final String titulo;
  
  /// Emoji para mostrar junto al título
  final String? emoji;
  
  /// El texto que se muestra como placeholder
  final String textoPlaceholder;
  
  /// Código de país inicial (ISO 3166-1 alpha-2, ej: "US", "MX", "ES")
  final String? codigoPaisInicial;
  
  /// Callback cuando se selecciona un país
  /// Recibe el código del país (ISO 3166-1 alpha-2)
  final Function(String codigoPais)? onChanged;

  const CountryPickerWidget({
    super.key,
    required this.titulo,
    this.emoji,
    required this.textoPlaceholder,
    this.codigoPaisInicial,
    this.onChanged,
  });

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    // Si hay un código de país inicial, intentar obtener el país
    if (widget.codigoPaisInicial != null && widget.codigoPaisInicial!.isNotEmpty) {
      try {
        _selectedCountry = Country.parse(widget.codigoPaisInicial!);
      } catch (e) {
        // Si no se puede parsear, dejar en null
        _selectedCountry = null;
      }
    }
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      favorite: <String>['MX', 'US', 'ES'], // Países favoritos (opcional)
      showPhoneCode: false, // No mostrar código telefónico
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        // Llamar al callback con el código del país (ISO 3166-1 alpha-2)
        widget.onChanged?.call(country.countryCode);
      },
      // Personalizar el diálogo
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        textStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        searchTextStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        inputDecoration: InputDecoration(
          labelText: 'Buscar país',
          hintText: 'Escribe el nombre del país',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.emoji != null && widget.emoji!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  widget.emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            Expanded(
              child: Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _showCountryPicker,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.textoPlaceholder,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            child: Row(
              children: [
                if (_selectedCountry != null) ...[
                  // Mostrar bandera del país seleccionado
                  Text(
                    _selectedCountry!.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  // Mostrar nombre del país
                  Expanded(
                    child: Text(
                      _selectedCountry!.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ] else ...[
                  // Mostrar placeholder cuando no hay país seleccionado
                  Text(
                    'Selecciona un país',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

