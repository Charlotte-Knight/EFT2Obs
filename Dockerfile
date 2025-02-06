# syntax=docker/dockerfile:1

FROM almalinux:latest AS baseos
RUN dnf -y install \
 gcc-c++ \
 gfortran \
 cmake \
 perl \
 python-devel \
 python-yaml \
 python-six \
 zlib-devel \
 wget \
 vim \
 gzip \
 f2py \
 rsync \
 patch
WORKDIR /eft2obs
COPY env.sh .

FROM baseos AS lhapdf
COPY setup/setup_lhapdf.sh setup/setup_lhapdf.sh
RUN ./setup/setup_lhapdf.sh

FROM lhapdf AS mg5
COPY setup/setup_mg5.sh setup/setup_mg5.sh
COPY setup/*.patch setup/
COPY setup/WeightCorrector.h setup/
RUN ./setup/setup_mg5.sh

FROM baseos AS rivet
COPY setup/setup_rivet.sh setup/setup_rivet.sh
RUN ./setup/setup_rivet.sh

FROM rivet AS rivetplugins
COPY RivetPlugins RivetPlugins
COPY setup/setup_rivet_plugins.sh setup/setup_rivet_plugins.sh
RUN ./setup/setup_rivet_plugins.sh

FROM mg5 AS setup_models
COPY setup/setup_model.sh setup/setup_model.sh
RUN ./setup/setup_model.sh SMEFTsim_A_U35_alphaScheme_UFO_v2_1 SMEFTsim_MFV_MwScheme_UFO SMEFTsim_MFV_alphaScheme_UFO SMEFTsim_U35_MwScheme_UFO SMEFTsim_U35_alphaScheme_UFO SMEFTsim_general_MwScheme_UFO SMEFTsim_general_alphaScheme_UFO SMEFTsim_topU3l_MwScheme_UFO SMEFTsim_topU3l_alphaScheme_UFO SMEFTsim_top_MwScheme_UFO SMEFTsim_top_alphaScheme_UFO SMEFTatNLO 
# for propagator corrections
RUN sed -i 's/expansion_order = 0/expansion_order = 99/g' MG5_aMC_v*/models/SMEFTsim*/coupling_orders.py

FROM lhapdf AS setup_pdf
COPY setup/setup_pdf.sh setup/setup_pdf.sh
RUN ./setup/setup_pdf.sh NNPDF31_nnlo_as_0118_mc_hessian_pdfas NNPDF31_nnlo_as_0118_nf_4_mc_hessian NNPDF31_nnlo_hessian_pdfas NNPDF31_nnlo_as_0118_nf_4 PDF4LHC15_nlo_30_pdfas 

FROM baseos
# set up alias for python3 to fix Rivet bug
RUN ln -s /usr/bin/python3 /usr/bin/python
COPY --from=setup_pdf /eft2obs/lhapdf lhapdf
COPY --from=setup_models /eft2obs/MG5_aMC_v2_9_16 MG5_aMC_v2_9_16
COPY --from=rivet /eft2obs/rivet rivet
COPY --from=rivetplugins /eft2obs/RivetPlugins RivetPlugins
COPY . .
CMD ["bash"]
