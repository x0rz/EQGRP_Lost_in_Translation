__all__=["fuzzbunch", "emacs","notemacs","vi"]
import fuzzbunch,emacs,notemacs,vi
editingmodes=[fuzzbunch.FuzzbunchMode,emacs.EmacsMode,notemacs.NotEmacsMode,vi.ViMode]

#add check to ensure all modes have unique mode names
