'use client'

import { useState } from 'react'
import { GlassCard } from '@/components/ui/GlassCard'
import { GoldButton } from '@/components/ui/GoldButton'
import { ChevronDown, ChevronUp, Mail, MessageCircle } from 'lucide-react'

const FAQS = [
    {
        question: 'Como faço para agendar um corte?',
        answer: 'Basta acessar a página inicial, clicar em "Novo Agendamento", escolher o serviço, o barbeiro e o horário desejado.'
    },
    {
        question: 'Sou barbeiro, como cadastro minha barbearia?',
        answer: 'Entre em contato com o suporte para solicitar o cadastro da sua barbearia na plataforma BarberPremium.'
    },
    {
        question: 'Quais formas de pagamento são aceitas?',
        answer: 'O pagamento é feito diretamente na barbearia. Aceitamos dinheiro, PIX e cartões.'
    },
    {
        question: 'Posso cancelar um agendamento?',
        answer: 'Sim, você pode cancelar seus agendamentos através do painel "Meus Agendamentos" com até 1 hora de antecedência.'
    }
]

export default function SupportPage() {
    const [openIndex, setOpenIndex] = useState<number | null>(null)
    const [message, setMessage] = useState('')
    const [sending, setSending] = useState(false)

    const toggleFaq = (index: number) => {
        setOpenIndex(openIndex === index ? null : index)
    }

    const handleSendMessage = async (e: React.FormEvent) => {
        e.preventDefault()
        setSending(true)
        // Simulate sending email
        await new Promise(resolve => setTimeout(resolve, 1500))
        alert('Mensagem enviada com sucesso! Entraremos em contato em breve.')
        setMessage('')
        setSending(false)
    }

    return (
        <div className="min-h-screen bg-dark-bg p-8">
            <div className="max-w-4xl mx-auto">
                <h1 className="text-3xl font-bold text-white mb-8 text-center">Central de Ajuda</h1>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {/* FAQ Section */}
                    <div>
                        <h2 className="text-xl font-bold text-white mb-6 flex items-center gap-2">
                            <MessageCircle className="text-gold" /> Perguntas Frequentes
                        </h2>
                        <div className="space-y-4">
                            {FAQS.map((faq, index) => (
                                <GlassCard
                                    key={index}
                                    className="p-4 cursor-pointer transition-all hover:bg-white/10"
                                    onClick={() => toggleFaq(index)}
                                >
                                    <div className="flex justify-between items-center">
                                        <h3 className="text-white font-medium">{faq.question}</h3>
                                        {openIndex === index ? <ChevronUp className="text-gold w-4 h-4" /> : <ChevronDown className="text-gray-400 w-4 h-4" />}
                                    </div>
                                    {openIndex === index && (
                                        <p className="text-gray-400 mt-3 text-sm animate-in fade-in slide-in-from-top-2">
                                            {faq.answer}
                                        </p>
                                    )}
                                </GlassCard>
                            ))}
                        </div>
                    </div>

                    {/* Contact Form */}
                    <div>
                        <h2 className="text-xl font-bold text-white mb-6 flex items-center gap-2">
                            <Mail className="text-gold" /> Fale Conosco
                        </h2>
                        <GlassCard className="p-6">
                            <form onSubmit={handleSendMessage} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-300 mb-1">Assunto</label>
                                    <select className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-gold outline-none">
                                        <option>Dúvida Geral</option>
                                        <option>Problema Técnico</option>
                                        <option>Sugestão</option>
                                        <option>Parceria</option>
                                    </select>
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-300 mb-1">Mensagem</label>
                                    <textarea
                                        rows={5}
                                        value={message}
                                        onChange={(e) => setMessage(e.target.value)}
                                        className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white focus:border-gold outline-none resize-none"
                                        placeholder="Descreva sua dúvida ou problema..."
                                        required
                                    />
                                </div>

                                <GoldButton type="submit" isLoading={sending}>
                                    Enviar Mensagem
                                </GoldButton>
                            </form>
                        </GlassCard>
                    </div>
                </div>
            </div>
        </div>
    )
}
