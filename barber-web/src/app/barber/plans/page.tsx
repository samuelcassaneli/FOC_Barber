'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { Plus, Trash2, Edit2, Crown, Check } from 'lucide-react'
import Link from 'next/link'

type Plan = {
    id: string
    name: string
    price: number
    description: string
    benefits: string[]
}

export default function PlansPage() {
    const [plans, setPlans] = useState<Plan[]>([])
    const [loading, setLoading] = useState(true)
    const [isEditing, setIsEditing] = useState(false)
    const [currentPlan, setCurrentPlan] = useState<Partial<Plan>>({ benefits: [''] })

    useEffect(() => {
        fetchPlans()
    }, [])

    const fetchPlans = async () => {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) return

        const { data } = await supabase
            .from('membership_plans')
            .select('*')
            .eq('barber_id', user.id)

        if (data) setPlans(data)
        setLoading(false)
    }

    const handleSave = async () => {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) return

        const planData = {
            ...currentPlan,
            barber_id: user.id,
            price: Number(currentPlan.price)
        }

        if (currentPlan.id) {
            await supabase.from('membership_plans').update(planData).eq('id', currentPlan.id)
        } else {
            await supabase.from('membership_plans').insert([planData])
        }

        setIsEditing(false)
        setCurrentPlan({ benefits: [''] })
        fetchPlans()
    }

    const handleDelete = async (id: string) => {
        if (!confirm('Tem certeza?')) return
        await supabase.from('membership_plans').delete().eq('id', id)
        fetchPlans()
    }

    const updateBenefit = (index: number, value: string) => {
        const newBenefits = [...(currentPlan.benefits || [])]
        newBenefits[index] = value
        setCurrentPlan({ ...currentPlan, benefits: newBenefits })
    }

    const addBenefit = () => {
        setCurrentPlan({ ...currentPlan, benefits: [...(currentPlan.benefits || []), ''] })
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-4xl mx-auto">
                <header className="flex justify-between items-center mb-8">
                    <div>
                        <Link href="/barber" className="text-gray-400 hover:text-white text-sm mb-2 block">← Voltar ao Dashboard</Link>
                        <h1 className="text-3xl font-bold text-white">Planos de Assinatura</h1>
                        <p className="text-gray-400">Crie clubes de fidelidade para seus clientes</p>
                    </div>
                    <GoldButton className="w-auto flex items-center gap-2" onClick={() => setIsEditing(true)}>
                        <Plus className="w-4 h-4" /> Novo Plano
                    </GoldButton>
                </header>

                {isEditing && (
                    <GlassCard className="p-6 mb-8 border-gold/30">
                        <h2 className="text-xl font-bold text-white mb-4">{currentPlan.id ? 'Editar Plano' : 'Novo Plano'}</h2>
                        <div className="grid gap-4">
                            <div>
                                <label className="block text-sm text-gray-400 mb-1">Nome do Plano</label>
                                <input
                                    type="text"
                                    value={currentPlan.name || ''}
                                    onChange={e => setCurrentPlan({ ...currentPlan, name: e.target.value })}
                                    className="w-full bg-white/5 border border-white/10 rounded p-2 text-white"
                                    placeholder="Ex: Clube VIP"
                                />
                            </div>
                            <div>
                                <label className="block text-sm text-gray-400 mb-1">Preço Mensal (R$)</label>
                                <input
                                    type="number"
                                    value={currentPlan.price || ''}
                                    onChange={e => setCurrentPlan({ ...currentPlan, price: Number(e.target.value) })}
                                    className="w-full bg-white/5 border border-white/10 rounded p-2 text-white"
                                    placeholder="0.00"
                                />
                            </div>
                            <div>
                                <label className="block text-sm text-gray-400 mb-1">Benefícios</label>
                                {currentPlan.benefits?.map((benefit, idx) => (
                                    <div key={idx} className="flex gap-2 mb-2">
                                        <input
                                            type="text"
                                            value={benefit}
                                            onChange={e => updateBenefit(idx, e.target.value)}
                                            className="w-full bg-white/5 border border-white/10 rounded p-2 text-white"
                                            placeholder="Ex: Cortes ilimitados"
                                        />
                                    </div>
                                ))}
                                <button onClick={addBenefit} className="text-sm text-gold hover:underline">+ Adicionar Benefício</button>
                            </div>
                            <div className="flex justify-end gap-2 mt-4">
                                <button onClick={() => setIsEditing(false)} className="px-4 py-2 text-gray-400 hover:text-white">Cancelar</button>
                                <GoldButton className="w-auto" onClick={handleSave}>Salvar Plano</GoldButton>
                            </div>
                        </div>
                    </GlassCard>
                )}

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {plans.map(plan => (
                        <GlassCard key={plan.id} className="p-6 relative group hover:border-gold/50 transition-colors">
                            <div className="absolute top-4 right-4 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                <button onClick={() => { setCurrentPlan(plan); setIsEditing(true) }} className="p-2 bg-white/10 rounded-full hover:bg-white/20">
                                    <Edit2 className="w-4 h-4 text-white" />
                                </button>
                                <button onClick={() => handleDelete(plan.id)} className="p-2 bg-red-500/10 rounded-full hover:bg-red-500/20">
                                    <Trash2 className="w-4 h-4 text-red-400" />
                                </button>
                            </div>

                            <div className="flex items-center gap-3 mb-4">
                                <div className="p-3 bg-gold/10 rounded-xl">
                                    <Crown className="w-6 h-6 text-gold" />
                                </div>
                                <div>
                                    <h3 className="text-xl font-bold text-white">{plan.name}</h3>
                                    <p className="text-gold font-bold">R$ {plan.price.toFixed(2)}<span className="text-gray-400 text-sm font-normal">/mês</span></p>
                                </div>
                            </div>

                            <ul className="space-y-2">
                                {plan.benefits?.map((benefit, idx) => (
                                    <li key={idx} className="flex items-center gap-2 text-gray-300 text-sm">
                                        <Check className="w-3 h-3 text-green-400" /> {benefit}
                                    </li>
                                ))}
                            </ul>
                        </GlassCard>
                    ))}
                </div>
            </div>
        </div>
    )
}
