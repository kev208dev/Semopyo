import 'dart:ui';
import 'package:flutter/material.dart';
import 'color_set.dart';

const List<int> kSizeOptions = [250, 255, 260, 265, 270, 275, 280, 285, 290];
const String _kFallbackAsset = 'assets/images/nike-airforce107.png';

/// 네트워크 URL이면 NetworkImage, 아니면 asset. 실패하면 기본 에셋으로 폴백.
Widget shoeImage(
  String src, {
  double? width,
  Color? color,
  BlendMode? blendMode,
  BoxFit fit = BoxFit.contain,
}) {
  if (src.startsWith('http')) {
    return Image.network(
      src,
      width: width,
      color: color,
      colorBlendMode: blendMode,
      fit: fit,
      errorBuilder: (_, _, _) => Image.asset(
        _kFallbackAsset,
        width: width,
        color: color,
        colorBlendMode: blendMode,
        fit: fit,
      ),
    );
  }
  return Image.asset(
    src.isEmpty ? _kFallbackAsset : src,
    width: width,
    color: color,
    colorBlendMode: blendMode,
    fit: fit,
  );
}

/// 공중에 떠있는 듯한 큰 신발 카드.
/// - onSizeChanged 가 있으면 사이즈 드롭다운 편집 가능(현재 신발).
/// - feltSize 가 있으면 "체감 OOOmm" 칩 표시(새 신발).
class MainShoeCard extends StatelessWidget {
  const MainShoeCard({
    super.key,
    required this.brand,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.color,
    required this.labelSize,
    this.caption,
    this.feltSize,
    this.onSizeChanged,
  });

  final String brand;
  final String name;
  final String price;
  final String imageUrl;
  final String color;
  final int labelSize;
  final String? caption; // "현재 신는 신발" / "새로운 신발"
  final int? feltSize; // 체감 추천 라벨(mm)
  final ValueChanged<int>? onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final editable = onSizeChanged != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withAlpha(77),
              blurRadius: 15,
              offset: const Offset(5, 10),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: getColorSet(color),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 300,
        height: 360,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 175,
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price.isEmpty ? '' : '$price원',
                    style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (editable)
                    _SizeSelector(value: labelSize, onChanged: onSizeChanged!)
                  else
                    _SizeBadge(labelSize: labelSize, feltSize: feltSize),
                ],
              ),
              // 핑크 그림자 (floating)
              Positioned(
                right: -70,
                bottom: -11,
                child: Transform.rotate(
                  angle: -0.65,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Opacity(
                      opacity: 0.35,
                      child: SizedBox(
                        width: 300,
                        child: shoeImage(
                          imageUrl,
                          width: 300,
                          color: Colors.pink.withAlpha(200),
                          blendMode: BlendMode.srcATop,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 실제 신발 이미지
              Positioned(
                right: -70,
                bottom: -11,
                child: Transform.rotate(
                  angle: -0.65,
                  child: SizedBox(
                    width: 300,
                    child: shoeImage(imageUrl, width: 300),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final safe = kSizeOptions.contains(value) ? value : 270;
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: safe,
          isExpanded: true,
          dropdownColor: const Color(0xFF333333),
          iconEnabledColor: Colors.white,
          items: kSizeOptions
              .map(
                (s) => DropdownMenuItem<int>(
                  value: s,
                  child: Text(
                    'KR $s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _SizeBadge extends StatelessWidget {
  const _SizeBadge({required this.labelSize, this.feltSize});
  final int labelSize;
  final int? feltSize;

  @override
  Widget build(BuildContext context) {
    if (feltSize != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          '체감 ${feltSize}mm 추천',
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    return Text(
      'KR $labelSize',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// 선택 화면 상단 슬롯용 작은 floating 카드.
class SubShoeCard extends StatelessWidget {
  const SubShoeCard({
    super.key,
    required this.brand,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.caption,
    this.selected = false,
    this.badge,
  });

  final String brand;
  final String name;
  final String imageUrl;
  final String color;
  final String caption;
  final bool selected;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withAlpha(70),
            blurRadius: 14,
            offset: const Offset(4, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: getColorSet(color),
        ),
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(
                  width: 95,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              right: -28,
              bottom: -18,
              child: Transform.rotate(
                angle: -0.5,
                child: SizedBox(
                  width: 150,
                  child: shoeImage(imageUrl, width: 150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
