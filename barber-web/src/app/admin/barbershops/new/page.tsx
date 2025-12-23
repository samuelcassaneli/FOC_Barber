'use client'

import { useState } from 'react'
import { supabase } from '@/lib/supabase'
import { GlassCard } from '@/components/ui/GlassCard'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import {
    Store, ArrowLeft, Save, Shield,
    MapPin, Phone, Mail, Globe, Palette,
    Instagram, MessageCircle, CreditCard, Users
} from 'lucide-react'

interface BarbershopForm {
    name: string
    slug: string
    description: string
    phone: string
    whatsapp: string
    email: string
    owner_email: string
    website: string
    instagram: string
    address: string
    city: string
    state: string
    zip_code: string
    cnpj: string
    primary_color: string
    secondary_color: string
    plan_type: string
    max_barbers: number
    is_active: boolean
}

const BRAZILIAN_STATES = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
]

const PLAN_TYPES = [
    { value: 'free', label: 'Gratuito', barbers: 1 },
    { value: 'basic', label: 'Básico - R$ 49,90/mês', barbers: 3 },
    { value: 'premium', label: 'Premium - R$ 99,90/mês', barbers: 10 },
    { value: 'enterprise', label: 'Enterprise - R$ 249,90/mês', barbers: -1 },
]

export default function NewBarbershopPage() {
    const router = useRouter()
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [form, setForm] = useState<BarbershopForm>({
        name: '',
        slug: '',
        description: '',
        phone: '',
        whatsapp: '',
        email: '',
        owner_email: '',
        website: '',
        instagram: '',
        address: '',
        city: '',
        state: '',
        zip_code: '',
        cnpj: '',
        primary_color: '#D4AF37',
        secondary_color: '#1C1C1E',
        plan_type: 'free',
        max_barbers: 1,
        is_active: true
    })

    const generateSlug = (name: string) => {
        return name
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)/g, '')
    }

    const handleNameChange = (name: string) => {
        setForm(prev => ({
            ...prev,
            name,
            slug: generateSlug(name)
        }))
    }

    const handlePlanChange = (planType: string) => {
        const plan = PLAN_TYPES.find(p => p.value === planType)
        setForm(prev => ({
            ...prev,
            plan_type: planType,
            max_barbers: plan?.barbers || 1
        }))
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setLoading(true)
        setError(null)

        try {
            if (!form.name || !form.slug) {
                throw new Error('Nome e slug são obrigatórios')
            }

            if (!form.owner_email) {
                throw new Error('Email do proprietário é obrigatório')
            }

            // Check if slug is unique
            const { data: existing } = await supabase
                .from('barbershops')
                .select('id')
                .eq('slug', form.slug)
                .single()

            if (existing) {
                throw new Error('Este slug já está em uso. Escolha outro.')
            }

            // Get current user as admin
            const { data: { user } } = await supabase.auth.getUser()

            // Create barbershop
            const { data: barbershop, error: createError } = await supabase
                .from('barbershops')
                .insert({
                    name: form.name,
                    slug: form.slug,
                    description: form.description || null,
                    phone: form.phone || null,
                    whatsapp: form.whatsapp || null,
                    email: form.email || null,
                    owner_email: form.owner_email,
                    website: form.website || null,
                    instagram: form.instagram || null,
                    address: form.address || null,
                    city: form.city || null,
                    state: form.state || null,
                    zip_code: form.zip_code || null,
                    cnpj: form.cnpj || null,
                    primary_color: form.primary_color,
                    secondary_color: form.secondary_color,
                    plan_type: form.plan_type,
                    max_barbers: form.max_barbers,
                    is_active: form.is_active,
                    owner_id: null, // Será preenchido quando o dono se cadastrar
                    settings: {
                        booking_advance_days: 30,
                        min_booking_notice_hours: 2,
                        cancellation_policy_hours: 24,
                        allow_client_cancellation: true,
                        require_payment_upfront: false
                    }
                })
                .select()
                .single()

            if (createError) throw createError

            alert(`Barbearia criada com sucesso!\n\nCódigo de Convite: ${barbershop.invite_code}\n\nEnvie este código para o proprietário (${form.owner_email}) se cadastrar no app.`)

            router.push(`/admin/barbershops`)
        } catch (err: any) {
            setError(err.message || 'Erro ao criar barbearia')
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="min-h-screen bg-dark-bg">
            {/* Header */}
            <header className="bg-dark-card border-b border-white/10 px-8 py-4">
                <div className="max-w-7xl mx-auto flex justify-between items-center">
                    <div className="flex items-center gap-3">
                        <Shield className="text-gold" size={28} />
                        <h1 className="text-2xl font-bold text-white">FOC Barber Admin</h1>
                    </div>
                    <nav className="flex gap-6">
                        <Link href="/admin" className="text-gray-400 hover:text-white transition">Dashboard</Link>
                        <Link href="/admin/barbershops" className="text-gold font-medium">Barbearias</Link>
                    </nav>
                </div>
            </header>

            <main className="max-w-4xl mx-auto p-8">
                {/* Back Button */}
                <Link
                    href="/admin/barbershops"
                    className="inline-flex items-center gap-2 text-gray-400 hover:text-white transition mb-6"
                >
                    <ArrowLeft size={20} />
                    Voltar para Barbearias
                </Link>

                {/* Page Header */}
                <div className="flex items-center gap-4 mb-8">
                    <div className="w-16 h-16 bg-gold/20 rounded-xl flex items-center justify-center">
                        <Store className="text-gold" size={32} />
                    </div>
                    <div>
                        <h2 className="text-2xl font-bold text-white">Nova Barbearia</h2>
                        <p className="text-gray-400">Cadastre uma nova barbearia no sistema white-label</p>
                    </div>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit}>
                    {error && (
                        <div className="bg-red-500/20 border border-red-500/50 text-red-400 px-4 py-3 rounded-lg mb-6">
                            {error}
                        </div>
                    )}

                    {/* Basic Info */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4">Informações Básicas</h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Nome da Barbearia *</label>
                                <input
                                    type="text"
                                    value={form.name}
                                    onChange={(e) => handleNameChange(e.target.value)}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="Ex: Barbearia Premium"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Slug (URL) *</label>
                                <div className="flex items-center">
                                    <span className="text-gray-500 mr-2">/</span>
                                    <input
                                        type="text"
                                        value={form.slug}
                                        onChange={(e) => setForm(prev => ({ ...prev, slug: e.target.value }))}
                                        className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                        placeholder="barbearia-premium"
                                        required
                                    />
                                </div>
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">CNPJ</label>
                                <input
                                    type="text"
                                    value={form.cnpj}
                                    onChange={(e) => setForm(prev => ({ ...prev, cnpj: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="00.000.000/0001-00"
                                />
                            </div>
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Descrição</label>
                                <textarea
                                    value={form.description}
                                    onChange={(e) => setForm(prev => ({ ...prev, description: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50 h-24 resize-none"
                                    placeholder="Descrição da barbearia..."
                                />
                            </div>
                        </div>
                    </GlassCard>

                    {/* Owner Info */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <Users size={20} className="text-gold" />
                            Proprietário
                        </h3>
                        <div className="grid grid-cols-1 gap-4">
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Email do Proprietário *</label>
                                <input
                                    type="email"
                                    value={form.owner_email}
                                    onChange={(e) => setForm(prev => ({ ...prev, owner_email: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="dono@barbearia.com"
                                    required
                                />
                                <p className="text-gray-500 text-xs mt-1">
                                    O proprietário receberá um código para se cadastrar e acessar o painel da barbearia
                                </p>
                            </div>
                        </div>
                    </GlassCard>

                    {/* Plan */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <CreditCard size={20} className="text-gold" />
                            Plano
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Tipo de Plano</label>
                                <select
                                    value={form.plan_type}
                                    onChange={(e) => handlePlanChange(e.target.value)}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                >
                                    {PLAN_TYPES.map(plan => (
                                        <option key={plan.value} value={plan.value}>{plan.label}</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Máx. Barbeiros</label>
                                <input
                                    type="number"
                                    value={form.max_barbers === -1 ? 'Ilimitado' : form.max_barbers}
                                    disabled
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-gray-400 focus:outline-none"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Status</label>
                                <select
                                    value={form.is_active ? 'active' : 'inactive'}
                                    onChange={(e) => setForm(prev => ({ ...prev, is_active: e.target.value === 'active' }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                >
                                    <option value="active">Ativo</option>
                                    <option value="inactive">Inativo</option>
                                </select>
                            </div>
                        </div>
                    </GlassCard>

                    {/* Contact Info */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <Phone size={20} className="text-gold" />
                            Contato
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Telefone</label>
                                <input
                                    type="tel"
                                    value={form.phone}
                                    onChange={(e) => setForm(prev => ({ ...prev, phone: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="(11) 99999-9999"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">WhatsApp</label>
                                <input
                                    type="tel"
                                    value={form.whatsapp}
                                    onChange={(e) => setForm(prev => ({ ...prev, whatsapp: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="(11) 99999-9999"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">E-mail</label>
                                <input
                                    type="email"
                                    value={form.email}
                                    onChange={(e) => setForm(prev => ({ ...prev, email: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="contato@barbearia.com"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Instagram</label>
                                <input
                                    type="text"
                                    value={form.instagram}
                                    onChange={(e) => setForm(prev => ({ ...prev, instagram: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="@barbearia"
                                />
                            </div>
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Website</label>
                                <input
                                    type="url"
                                    value={form.website}
                                    onChange={(e) => setForm(prev => ({ ...prev, website: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="https://www.barbearia.com"
                                />
                            </div>
                        </div>
                    </GlassCard>

                    {/* Customization */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <Palette size={20} className="text-gold" />
                            Personalização (White-Label)
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Cor Primária</label>
                                <div className="flex gap-2">
                                    <input
                                        type="color"
                                        value={form.primary_color}
                                        onChange={(e) => setForm(prev => ({ ...prev, primary_color: e.target.value }))}
                                        className="w-12 h-12 rounded-lg border border-white/10 cursor-pointer"
                                    />
                                    <input
                                        type="text"
                                        value={form.primary_color}
                                        onChange={(e) => setForm(prev => ({ ...prev, primary_color: e.target.value }))}
                                        className="flex-1 bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    />
                                </div>
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Cor Secundária</label>
                                <div className="flex gap-2">
                                    <input
                                        type="color"
                                        value={form.secondary_color}
                                        onChange={(e) => setForm(prev => ({ ...prev, secondary_color: e.target.value }))}
                                        className="w-12 h-12 rounded-lg border border-white/10 cursor-pointer"
                                    />
                                    <input
                                        type="text"
                                        value={form.secondary_color}
                                        onChange={(e) => setForm(prev => ({ ...prev, secondary_color: e.target.value }))}
                                        className="flex-1 bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    />
                                </div>
                            </div>
                        </div>
                    </GlassCard>

                    {/* Address */}
                    <GlassCard className="p-6 mb-6">
                        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
                            <MapPin size={20} className="text-gold" />
                            Endereço
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="col-span-2">
                                <label className="block text-gray-400 text-sm mb-2">Endereço</label>
                                <input
                                    type="text"
                                    value={form.address}
                                    onChange={(e) => setForm(prev => ({ ...prev, address: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="Rua, número, complemento"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Cidade</label>
                                <input
                                    type="text"
                                    value={form.city}
                                    onChange={(e) => setForm(prev => ({ ...prev, city: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="São Paulo"
                                />
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">Estado</label>
                                <select
                                    value={form.state}
                                    onChange={(e) => setForm(prev => ({ ...prev, state: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                >
                                    <option value="">Selecione...</option>
                                    {BRAZILIAN_STATES.map(state => (
                                        <option key={state} value={state}>{state}</option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="block text-gray-400 text-sm mb-2">CEP</label>
                                <input
                                    type="text"
                                    value={form.zip_code}
                                    onChange={(e) => setForm(prev => ({ ...prev, zip_code: e.target.value }))}
                                    className="w-full bg-dark-bg border border-white/10 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-gold/50"
                                    placeholder="00000-000"
                                />
                            </div>
                        </div>
                    </GlassCard>

                    {/* Actions */}
                    <div className="flex gap-4">
                        <Link
                            href="/admin/barbershops"
                            className="flex-1 text-center py-3 border border-white/20 text-gray-400 rounded-lg hover:bg-white/5 transition"
                        >
                            Cancelar
                        </Link>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex-1 flex items-center justify-center gap-2 bg-gold text-black py-3 rounded-lg font-medium hover:bg-gold/90 transition disabled:opacity-50"
                        >
                            {loading ? (
                                'Criando...'
                            ) : (
                                <>
                                    <Save size={20} />
                                    Criar Barbearia
                                </>
                            )}
                        </button>
                    </div>
                </form>
            </main>
        </div>
    )
}
