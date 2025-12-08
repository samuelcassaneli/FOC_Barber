import { cn } from '@/lib/utils'
import { Loader2 } from 'lucide-react'

interface GoldButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    isLoading?: boolean
}

export function GoldButton({ children, className, isLoading, disabled, ...props }: GoldButtonProps) {
    return (
        <button
            disabled={disabled || isLoading}
            className={cn(
                "w-full bg-gradient-to-r from-[#D4AF37] to-[#F2D06B] text-black font-bold py-3 px-6 rounded-lg shadow-lg hover:shadow-gold/50 transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center",
                className
            )}
            {...props}
        >
            {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            {children}
        </button>
    )
}
