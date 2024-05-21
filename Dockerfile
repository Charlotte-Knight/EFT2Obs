# syntax=docker/dockerfile:1

FROM almalinux:latest
RUN dnf -y install gcc-c++ gfortran cmake perl python-devel python-yaml python-six zlib-devel wget vim gzip f2py rsync patch

WORKDIR /eft2obs

COPY env.sh .

COPY setup/setup_lhapdf.sh setup/setup_lhapdf.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_lhapdf.sh

COPY setup/setup_mg5.sh setup/setup_mg5.sh
COPY setup/*.patch setup/
COPY setup/WeightCorrector.h setup/
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_mg5.sh

COPY setup/setup_rivet.sh setup/setup_rivet.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_rivet.sh

COPY RivetPlugins RivetPlugins
COPY setup/setup_rivet_plugins.sh setup/setup_rivet_plugins.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_rivet_plugins.sh

COPY setup/setup_model.sh setup/setup_model.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_model.sh SMEFTsim_A_U35_alphaScheme_UFO_v2_1 SMEFTsim_MFV_MwScheme_UFO SMEFTsim_MFV_alphaScheme_UFO SMEFTsim_U35_MwScheme_UFO SMEFTsim_U35_alphaScheme_UFO SMEFTsim_general_MwScheme_UFO SMEFTsim_general_alphaScheme_UFO SMEFTsim_topU3l_MwScheme_UFO SMEFTsim_topU3l_alphaScheme_UFO SMEFTsim_top_MwScheme_UFO SMEFTsim_top_alphaScheme_UFO SMEFTatNLO 

COPY setup/setup_pdf.sh setup/setup_pdf.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_pdf.sh NNPDF31_nnlo_as_0118_mc_hessian_pdfas NNPDF31_nnlo_as_0118_nf_4_mc_hessian NNPDF31_nnlo_hessian_pdfas NNPDF31_nnlo_as_0118_nf_4 
#NNPDF40_nnlo_as_01180 NNPDF40_nnlo_as_01180_hessian NNPDF23_nlo_as_0119

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY . .

CMD ["bash"]
