<template>
  <div class="bg-white rounded-xl p-6 shadow-sm">
    <div class="flex items-center justify-between mb-3">
      <span class="text-sm font-medium text-gray-500">{{ title }}</span>
      <div
        class="w-8 h-8 rounded-lg flex items-center justify-center"
        :class="iconBg"
      >
        <UIcon :name="icon" class="w-4 h-4" :class="iconColor" />
      </div>
    </div>
    <p class="text-3xl font-bold text-gray-900">
      {{ value.toLocaleString() }}
    </p>
    <p v-if="sub" class="text-xs text-gray-400 mt-1">{{ sub }}</p>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  title: string
  value: number
  sub?: string
  icon: string
  color: 'green' | 'blue' | 'purple' | 'yellow' | 'red'
}>()

const colorMap = {
  green: { bg: 'bg-green-50', icon: 'text-green-600' },
  blue: { bg: 'bg-blue-50', icon: 'text-blue-600' },
  purple: { bg: 'bg-purple-50', icon: 'text-purple-600' },
  yellow: { bg: 'bg-yellow-50', icon: 'text-yellow-600' },
  red: { bg: 'bg-red-50', icon: 'text-red-600' },
}

const iconBg = computed(() => colorMap[props.color].bg)
const iconColor = computed(() => colorMap[props.color].icon)
</script>
