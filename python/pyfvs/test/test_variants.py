'''
Created on Jan 12, 2016

@author: THAREN
'''
import os
import unittest
import pytest
import pandas as pd
import numpy as np

import pyfvs
from pyfvs import fvs

variants = [('pnc',), ('wcc',), ('soc',), ('cac',), ('oc',), ('op',)]

root = os.path.split(__file__)[0]
bare_ground_params = [
        ['pnc', 'rmrs/pn_bareground.key', 'rmrs/pn_bareground.sum.save'],
        ['wcc', 'rmrs/wc_bareground.key', 'rmrs/wc_bareground.sum.save'],
        ['soc', 'rmrs/so_bareground.key', 'rmrs/so_bareground.sum.save'],
        ['cac', 'rmrs/ca_bareground.key', 'rmrs/ca_bareground.sum.save'],
        ['oc', 'rmrs/oc_bareground.key', 'rmrs/oc_bareground.sum.save'],
        ['op', 'rmrs/op_bareground.key', 'rmrs/op_bareground.sum.save'],
        ]

@pytest.mark.parametrize(('variant',), variants)
def test_load_variant(variant):
    """
    Test that variant libraries load and initialize.
    """
    try:
        f = fvs.FVS(variant)

    except ImportError:
        pytest.skip('No variant library: {}'.format(variant))
        return None

    except:
        raise

    assert f.variant == variant
    assert not f.fvslib is None
    f = None

@pytest.mark.parametrize(('variant', 'kwd_path', 'sum_path'), bare_ground_params)
def test_bare_ground(variant, kwd_path, sum_path):
    try:
        f = fvs.FVS(variant)

    except ImportError:
        pytest.skip('No variant library: {}'.format(variant))
        return None

    except:
        raise

    f.init_projection(os.path.join(root, kwd_path))

    for c in range(f.contrl_mod.ncyc):
        r = f.grow_projection()

    r = f.end_projection()
    assert r == 0

    widths = [4, 4, 6, 4, 5, 4, 4, 5, 6, 6, 6, 6, 6, 6, 6, 4, 5, 4, 4, 5, 8, 5, 6, 8, 4, 2, 1]
    fldnames = (
            'year,age,tpa,baa,sdi,ccf,top_ht,qmd,total_cuft'
            ',merch_cuft,merch_bdft,rem_tpa,rem_total_cuft'
            ',rem_merch_cuft,rem_merch_bdft,res_baa,res_sdi'
            ',res_ccf,res_top_ht,resid_qmd,grow_years'
            ',annual_acc,annual_mort,mai_merch_cuft,for_type'
            ',size_class,stocking_class'
            ).split(',')

    # Read the sum file generated by the "official" FVS executable
    sum_check = pd.read_fwf(os.path.join(root, sum_path), skiprows=1, widths=widths)
    sum_check.columns = fldnames

    # Read the sum file produced by the pyfvs variant wrapper
    p = os.path.join(root, os.path.splitext(sum_path)[0])
    sum_test = pd.read_fwf(p, skiprows=1, widths=widths)
    sum_test.columns = fldnames

    for fld in fldnames[:18]:
        assert np.all(np.isclose(sum_check.loc[:, fld], sum_test.loc[:, fld], atol=1))

if __name__ == '__main__':
    test_bare_ground(*bare_ground_params[0])

