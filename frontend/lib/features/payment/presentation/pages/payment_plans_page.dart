import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentPlansPage extends ConsumerWidget {
  const PaymentPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프리미엄 플랜'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            '무제한 대화를 즐기세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '프리미엄 멤버가 되어 더 많은 기능을 사용하세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Monthly Subscription
          _buildPlanCard(
            context,
            title: '프리미엄 월간 구독',
            price: '₩29,900',
            period: '/월',
            features: [
              '무제한 대화 시간',
              '무제한 대화 요청',
              '우선 매칭',
              '광고 제거',
              '프로필 하이라이트',
            ],
            isRecommended: true,
            onTap: () => _handlePurchase(context, 'subscription_monthly'),
          ),
          const SizedBox(height: 16),

          // Chat Pack 50
          _buildPlanCard(
            context,
            title: '대화 50회권',
            price: '₩19,900',
            period: '',
            features: [
              '50회 대화 요청',
              '구매 후 30일간 유효',
            ],
            onTap: () => _handlePurchase(context, 'chat_pack_50'),
          ),
          const SizedBox(height: 16),

          // Chat Pack 30
          _buildPlanCard(
            context,
            title: '대화 30회권',
            price: '₩14,900',
            period: '',
            features: [
              '30회 대화 요청',
              '구매 후 30일간 유효',
            ],
            onTap: () => _handlePurchase(context, 'chat_pack_30'),
          ),
          const SizedBox(height: 16),

          // Chat Pack 10
          _buildPlanCard(
            context,
            title: '대화 10회권',
            price: '₩9,900',
            period: '',
            features: [
              '10회 대화 요청',
              '구매 후 30일간 유효',
            ],
            onTap: () => _handlePurchase(context, 'chat_pack_10'),
          ),
          const SizedBox(height: 32),

          // Terms
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '구독은 자동 갱신되며, 언제든지 취소할 수 있습니다.\n결제 시 이용약관 및 개인정보 처리방침에 동의하는 것으로 간주됩니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isRecommended ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommended badge
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '추천',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isRecommended) const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  if (period.isNotEmpty)
                    Text(
                      period,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Features
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('결제 확인'),
        content: const Text('이 플랜을 구매하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Process payment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('결제 처리 중...')),
              );
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}
