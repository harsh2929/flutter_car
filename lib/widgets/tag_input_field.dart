import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  final Function(List<String>) onTagsChanged;
  final List<String>? initialTags;

  TagInputField({required this.onTagsChanged, this.initialTags});

  @override
  _TagInputFieldState createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _textController = TextEditingController();
  late List<String> tags;

  @override
  void initState() {
    super.initState();
    tags = widget.initialTags != null ? List<String>.from(widget.initialTags!) : [];
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        widget.onTagsChanged(tags);
      });
      _textController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
      widget.onTagsChanged(tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags'),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: tags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: Icon(Icons.close),
              onDeleted: () => _removeTag(tag),
            );
          }).toList(),
        ),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Add a tag',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addTag(_textController.text.trim()),
            ),
          ),
          onSubmitted: (value) => _addTag(value.trim()),
        ),
      ],
    );
  }
}
