# NivOS Project Rules & Principles

This workspace uses pstack (`poteto-mode`). All changes must adhere to the engineering standards and principles defined in `.agents/skills/`.

## Active principles

- **principle-foundational-thinking**: Define data structures, build artifacts, and dependency chains before writing shell scripts or build logic.
- **principle-prove-it-works**: Verify builds against tangible artifacts (bootable image, rootfs tarball, or kernel binary) rather than assuming a script will run cleanly.
- **principle-model-the-domain**: Separate kernel build stages, rootfs assembling, and ISO creation into distinct, reproducible steps.
- **principle-make-operations-idempotent**: Build pipelines must handle interrupts and cache downloads cleanly without corrupting target states.
- **unslop**: Keep prose concise, active, and free of conversational padding or decorative elements.
