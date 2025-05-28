import 'package:flutter/material.dart';
import 'package:smartchef/views/utils/AppColor.dart';

class SearchFilterModal extends StatefulWidget {
  final String? selectedFilter;
  final Function(String) onFilterSelected;

  const SearchFilterModal({super.key, this.selectedFilter, required this.onFilterSelected});

  @override
  _SearchFilterModalState createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> {
  late String? _selectedFilter;

  final List<String> filtros = [
    'Iniciante',
    'Intermediário',
    'Avançado',
    'Normal',
    'Vegetariano',
    'Saudável',
    'Até 30 minutos',
    '30 a 60 minutos',
    'Mais de 1 hora',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  void _aplicarFiltro(String filtro) {
    setState(() => _selectedFilter = filtro);
    widget.onFilterSelected(filtro);
    Navigator.of(context).pop();
  }

  void _resetarFiltro() {
    setState(() => _selectedFilter = null);
    widget.onFilterSelected('');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: AppColor.primaryExtraSoft,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _resetarFiltro,
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Resetar', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
              Text(
                'Filtrar por',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'inter'),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
        for (var filtro in filtros)
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: ListTileTheme(
              selectedColor: AppColor.primary,
              textColor: Colors.grey,
              child: ListTile(
                selected: _selectedFilter == filtro,
                onTap: () => _aplicarFiltro(filtro),
                title: Text(filtro, style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          ),
      ],
    );
  }
}