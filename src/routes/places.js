import express from 'express';
import { getPlaces, getPlaceById } from '../controllers/placesController.js';

const router = express.Router();

router.get('/', getPlaces);
router.get('/:id', getPlaceById);

export default router;