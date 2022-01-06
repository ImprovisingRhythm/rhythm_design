import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../utils/ui_designer.dart';
import 'input.dart';

class CodeInput extends StatefulWidget {
  const CodeInput({
    Key? key,
    required this.onCompleted,
    required this.onEditing,
    this.keyboardType = TextInputType.number,
    this.length = 4,
    this.itemSize = 50,
    this.itemSpacing = 20.0,
    this.decoration,
    this.textStyle,
    this.autofocus = false,
    this.isSecure = false,
    this.digitsOnly = true,
  }) : super(key: key);

  final ValueChanged<String> onCompleted;
  final ValueChanged<bool> onEditing;
  final TextInputType keyboardType;
  final int length;
  final double itemSize;
  final double itemSpacing;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final bool autofocus;
  final bool isSecure;
  final bool digitsOnly;

  @override
  _CodeInputState createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _listFocusNode = <FocusNode>[];
  final _listFocusNodeKeyListener = <FocusNode>[];
  final _listControllerText = <TextEditingController>[];
  final _code = <String>[];

  int _currentIndex = 0;

  @override
  void initState() {
    _listFocusNode.clear();
    _listFocusNodeKeyListener.clear();

    for (var i = 0; i < widget.length; i++) {
      _listFocusNode.add(FocusNode());
      _listFocusNodeKeyListener.add(FocusNode());
      _listControllerText.add(TextEditingController());
      _code.add('');
    }

    super.initState();
  }

  void clearAll() {
    widget.onEditing(true);

    for (var i = 0; i < widget.length; i++) {
      _listControllerText[i].text = '';
    }

    if (mounted) {
      setState(() {
        _currentIndex = 0;
        FocusScope.of(context).requestFocus(_listFocusNode[0]);
      });
    }
  }

  String _getInputVerify() {
    String verifyCode = '';

    for (var i = 0; i < widget.length; i++) {
      for (var index = 0; index < _listControllerText[i].text.length; index++) {
        if (_listControllerText[i].text[index] != '') {
          verifyCode += _listControllerText[i].text[index];
        }
      }
    }

    return verifyCode;
  }

  Widget _buildInputItem(int index) {
    return Input(
      keyboardType: widget.keyboardType,
      inputFormatters: widget.digitsOnly
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      maxLines: 1,
      maxLength: widget.length - index,
      controller: _listControllerText[index],
      focusNode: _listFocusNode[index],
      showCursor: true,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      autocorrect: false,
      textAlign: TextAlign.center,
      autofocus: widget.autofocus,
      style: widget.textStyle,
      onChanged: (value) {
        if ((_currentIndex + 1) == widget.length && value.isNotEmpty) {
          widget.onEditing(false);
        } else {
          widget.onEditing(true);
        }

        if (value.isEmpty && index > 0) {
          _prev(index);
          return;
        }

        if (value.isNotEmpty) {
          String _value = value;
          int _index = index;

          while (_value.isNotEmpty && _index < widget.length) {
            _listControllerText[_index].value =
                TextEditingValue(text: _value[0]);

            _next(_index++);
            _value = _value.substring(1);
          }

          if (_listControllerText[widget.length - 1].value.text.length == 1 &&
              _getInputVerify().length == widget.length) {
            widget.onEditing(false);
            widget.onCompleted(_getInputVerify());
          }
        }
      },
    );
  }

  void _next(int index) {
    if (index == widget.length - 1) {
      _listControllerText[index].selection =
          TextSelection.fromPosition(const TextPosition(offset: 1));
    } else {
      setState(() {
        _currentIndex = index + 1;
      });

      FocusScope.of(context).requestFocus(_listFocusNode[_currentIndex]);
    }
  }

  void _prev(int index) {
    if (index > 0) {
      setState(() {
        if (_listControllerText[index].text.isEmpty) {}
        _currentIndex = index - 1;
      });

      FocusScope.of(context).requestFocus(FocusNode());
      FocusScope.of(context).requestFocus(_listFocusNode[_currentIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: spacingX(widget.itemSpacing, [
        for (var index = 0; index < widget.length; index++)
          Container(
            height: widget.itemSize,
            width: widget.itemSize,
            alignment: Alignment.center,
            decoration: widget.decoration,
            child: _buildInputItem(index),
          )
      ]),
    );
  }
}
