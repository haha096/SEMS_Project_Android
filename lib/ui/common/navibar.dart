import 'package:flutter/material.dart';
import '../../src/constants.dart';

class SemsNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SemsNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _item({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 선택 시 아이콘 뒤 살짝 하이라이트
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // 라벨은 연한 흰색(선택 시 불투명도↑)
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(selected ? 1.0 : 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            _item(
              icon: Icons.tune, label: '제어',
              selected: currentIndex == 1,
              onPressed: () => onTap(1),
            ),
            _item(
              icon: Icons.home, label: '메인',
              selected: currentIndex == 0,
              onPressed: () => onTap(0),
            ),
            _item(
              icon: Icons.person, label: '내정보',
              selected: currentIndex == 2,
              onPressed: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}