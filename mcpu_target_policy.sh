# Shared CPU classification rules for the supported-CPU reports.

# The SiFive toolchain may expose CPUs from other vendors. Keep these vendor
# prefixes out of the SiFive report while retaining vendor-neutral targets.
mcpu_is_non_sifive_vendor() {
    case "$1" in
        andes|andes-*|\
        mips|mips-*|\
        spacemit|spacemit-*|\
        syntacore|syntacore-*|\
        thead|thead-*|\
        tt|tt-*|\
        veyron|veyron-*|\
        xiangshan|xiangshan-*|\
        rp2350-* )
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Clang's `-mcpu=help` includes these names even though, in every configured
# toolchain version, they are accepted by -mtune and rejected by -mcpu. Keep
# this list exact: the help catalog alone does not establish -mcpu support, and
# a family-wide pattern could hide future CPUs. Recheck these results when the
# configured toolchain matrix changes.
clang_mcpu_is_tune_only() {
    case "$1" in
        sifive-6-series|\
        sifive-7m-series|\
        sifive-7n-series|\
        sifive-7o-series|\
        sifive-7-series|\
        sifive-8-series|\
        sifive-p400-series|\
        sifive-p500-series|\
        sifive-p600-series)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
